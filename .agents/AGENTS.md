# Agent notes (project)

## Monetization / premium residual (2026-07)

- **No real billing** is implemented in this Flutter app.
- Fields named `isPremium` on thinking methods / morphological templates / persona packs are **legacy residual metadata**. Values are forced to `false` with inline comments.
- Tree skin “shop” is a **local unlock simulation** (`purchaseUserSkin` writes SQLite only). UI copy was rewritten to say so.
- **Do not** implement paywalls, IAP, or entitlement gates from these remnants unless the product owner explicitly decides monetization.

See also conversation artifact `residu_premium_disabled.md` if present in the agent brain folder.
