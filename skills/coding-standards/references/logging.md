# Coding Standards — Logging

> Part of the `coding-standards` skill. Section numbers are kept so references like "section 5.4" stay valid.

### 5.4 Logging: Error Log vs Audit Log

Two different concepts that often get mixed — separate them clearly, because their purpose, content, and readers differ:

| | **Error Log** | **Audit Log** |
|---|---|---|
| Purpose | Debugging — why the system failed/errored | Traceability — who did what, when, for compliance/investigation |
| Content | Stack trace, request context, technical error message | Actor, action, affected entity, before/after values |
| Retention | Usually short (rolling/a few weeks), high volume | Long/permanent, more controlled volume |
| Readers | Developers while debugging | Admin/GA/audit/compliance during investigation |
| Example | "NullPointerException in OrderService.calculateTotal, line 42" | "User `usr-123` (GA) changed employee `usr-456`'s `subsidy_amount` from 10000 to 15000 on 2026-08-11 10:30" |

#### Error Log

**Structured logging is mandatory** — not free-form `console.log`/`fmt.Println` strings, so logs can be queried and filtered in a log aggregator (if any):

```typescript
// NestJS — use a logger service (winston/pino), not console.log
this.logger.error('Failed to process order', {
  orderId: order.id,
  userId: order.user_id,
  error: err.message,
  stack: err.stack,
});
```
```go
// Golang — structured logger (zerolog/zap), not fmt.Println
logger.Error().
    Str("order_id", orderID).
    Str("user_id", userID).
    Err(err).
    Msg("failed to process order")
```

**Log levels** are used consistently by severity:
- `debug` — technical detail for development, disabled in production (or filtered)
- `info` — normal events useful for tracing flow (request received, job finished)
- `warn` — something not ideal but the system still runs (retry, fallback to default)
- `error` — an operation failed, needs attention but the system is still alive
- `fatal`/`panic` — the system cannot continue, usually followed by a crash/restart

**Required in every error log:** enough context to reproduce without asking the user back — `request_id`/`trace_id` (to correlate logs within the same request), `user_id` if relevant, the failed endpoint/operation, the original error message.

**Never log sensitive data:** passwords (even hashed), tokens/API keys, full credit card numbers, unnecessary personal data (full NIK, etc.) — mask/redact if the field must appear in the log for context (`user_id` is allowed, `user.password_hash` is not).

#### Audit Log

Needed for actions that **change important data** and must be traceable to who is responsible — especially admin/privileged actions that change other people's data (e.g. an admin changing an employee's `subsidy_amount`, a Super Admin turning a feature on/off).

**When an audit log is mandatory** (not every action needs one; don't overdo it):
- Changes to financial/subsidy/pricing data by an admin
- Changes to system configuration with wide impact (feature toggles, changing global business rules)
- Privileged actions that change another user's data (admin edits/deletes user data)
- Login/access to sensitive data (if relevant for compliance)

**Audit log table — follows the database conventions in section 2.5:**
```
audit_logs
├── id (PK)
├── actor_id        (FK to users — who performed the action)
├── action           (string — "update_subsidy", "toggle_rfid", "delete_user", etc. — consistently snake_case)
├── entity_type       (string — "user", "catering_settings", etc. — name of the affected table)
├── entity_id          (uuid — id of the affected row)
├── before_value        (jsonb, nullable — state before the change)
├── after_value          (jsonb, nullable — state after the change)
├── ip_address            (nullable)
├── created_at
```
- `before_value`/`after_value` only need the changed fields, not the whole row if the row is large
- Audit logs are **never updated or deleted** once created (append-only) — if a correction is needed, create a new entry; don't edit the old one (the audit trail's integrity breaks if entries can be changed)
- Audit logs are written in the service layer (after the action succeeds), not in the controller/handler — so they stay consistent even when many entry points trigger the same action
