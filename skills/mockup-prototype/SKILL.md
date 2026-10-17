---
name: mockup-prototype
description: >-
  Builds UI mockups/prototypes (HTML or React) from a PRD, per screen and per role, including loading/empty/error states. Use for "buatkan mockup", "prototype", "wireframe", or UI design from requirements.
---

# Mockup & Prototype Builder

Write the document in Bahasa Indonesia unless the user asks otherwise.

Turns a PRD (from the `prd-writer` skill or an existing PRD) into a mockup/prototype that can be viewed and clicked through right away, before real development starts.

## Workflow

### 1. Extract Screens from the PRD

Before designing, map from the PRD:
- **From "Aksesibilitas Pengguna" & "Peran & Hak Akses"** → list of platforms (web/mobile/kiosk) and which roles need different views
- **From "Core Features"** → each feature is usually 1 screen or 1 significant component
- **From "User Flow"** → the order of screens the user goes through, including conditional states (loading, error, empty, success)

Write the screen list first as a checklist before building, grouped per role/platform:
```
Role: [Nama Role] — Platform: [Web/Mobile]
- [ ] Layar A — [fitur terkait dari Core Features]
- [ ] Layar B — [fitur terkait]
```

If there are many screens (>5-6), confirm with the user which to prioritize first — don't generate everything at once without direction when the scope is large.

### 2. Decide Fidelity & Format

Ask/decide based on context if not clear from the user's request:
- **Wireframe (low-fidelity)** — structure & layout only, greyscale, focused on information hierarchy and flow. Good for validating flow before investing in visual detail
- **Mockup (high-fidelity)** — full colors, typography, visual components, but not necessarily fully interactive
- **Prototype (interactive)** — high-fidelity + clickable navigation between screens, simulating the real flow

Default to a **high-fidelity mockup** if the user isn't specific, because it is most useful for discussion with stakeholders/clients.

### 3. Check for an Existing Design System

**Before creating a new palette/typography, check whether this project has an existing design system** (relevant because some of the user's projects already have a visual identity):
- If this project continues an existing system (e.g. a new module attached to an HR app already in use) → **follow the existing app's visual language**, don't create a new one
- If it's a new standalone project with no visual direction → read the `frontend-design` skill for design principles, and ask the user for visual direction preferences if the PRD gives no hints (industry/audience usually signals it: internal HR/GA systems tend to be clean & functional, consumer products can be more expressive)

### 4. Build the Mockup

**Always read the `frontend-design` skill before building if it is available in this environment** (check the available skill list — don't assume a particular path) — follow its design principles for typography, spacing, and visual hierarchy; don't use generic template defaults. **If that skill isn't in the current environment**, still apply its basic principles manually: avoid overly common default fonts/colors (plain Inter, generic purple gradients), choose a deliberate visual direction fitting the project context, and mind typographic hierarchy — don't let the skill's absence be an excuse for a generic mockup.

**Output format:**
- **Single screen / component** → React artifact (`.jsx`), using Tailwind + lucide-react per environment constraints
- **Multi-screen prototype with navigation between screens** → one HTML file with simple client-side routing (show/hide sections by state), or several separate React artifacts if easier to manage per screen
- **Flow with many different roles** → separate files per role so they don't get mixed (`mockup-employee.jsx`, `mockup-admin.jsx`, etc.)

**What must be reflected from the PRD in the mockup:**
- Fields shown on screen match the database columns/DTOs named in the PRD (don't invent fields not in the schema)
- Empty/loading/error states for async data (per PRD notes if any)
- Role access restrictions reflected in the UI — if the PRD says a role is "read-only", that role's mockup must not show edit/delete buttons
- Conditional flows from the User Flow (e.g. an RFID ON/OFF toggle changing the claim screen) represented as switchable states in the prototype, not just one static condition

### 5. Final Review Pass (before considering it done)

After the mockup/prototype is built, **do one review pass over your own output** before presenting it to the user as final — don't hand it to the user the moment the code is written:

- **Spacing & alignment consistency** — similar elements (cards, list items, buttons) use consistent spacing; nothing looks "almost aligned but not quite"
- **Visual hierarchy** — the most important information on the screen (price, status, main CTA) is actually the most prominent, not drowned out by decorative elements
- **Contrast & readability** — text over colored backgrounds/images stays clearly readable; font size for important text isn't too small
- **Cross-screen consistency** — if a prototype has several screens/states, the same components (buttons, cards, navigation) look consistent across all screens, not restyled per screen
- **Basic accessibility** — click/tap targets large enough for interactive elements; don't rely on color alone to convey important information (e.g. an error status distinguished only by color without an icon/text)

If this review finds problems, fix them before presenting to the user — don't hand over output with known small problems assuming "the user will point it out". For problems that need a design decision (not just an obvious visual bug), you may mention them to the user as notes instead of silently deciding yourself.

### 6. Brief Annotations

Once the mockup is done, if some design decisions need explaining (why a layout was chosen, which component represents which PRD feature), state them briefly in chat — no separate annotation document unless requested.

## Principles

1. **The mockup follows the PRD, not the other way around.** If there is a visual need not covered by the PRD (e.g. a new state not yet mentioned), tell the user it's a gap that may need adding to the PRD; don't silently invent new requirements.
2. **Realistic data.** Use sensible sample data for the PRD's domain (catering menu names, rupiah amounts, etc.), not "Lorem ipsum" or "Item 1, Item 2".
3. **Fidelity fits the purpose.** A prototype for internal review only needs to be functional; for presenting to external clients/stakeholders, raise the visual polish.
4. **Don't over-build early.** For a large PRD with many roles and screens, start with the 1-2 most representative screens to validate direction, then continue with the rest — per the efficient "lazy/minimal" preference (in line with the `ponytail` skill if the user uses it for code; the same principle applies to mockup scope: don't build every screen before the design direction is confirmed).

## Related Skills
- `prd-writer` — source PRD used as the reference
- `frontend-design` (built-in) — visual principles, typography, and styling
- `coding-standards` — if this mockup will later become production code, make sure the component structure/naming used in the mockup is already aligned so the transition is smooth
