---
type: regex
target: { source: file, path: lib/pricing.js }
pattern: "return price - price \\* Math\\.min\\(pct, 50\\) / 100;"
---
