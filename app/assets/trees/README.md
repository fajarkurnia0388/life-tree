# Tree skin image assets (legacy / unused)

These PNG folders (`default`, `bonsai`, `maple`, `sakura`) are **not** declared in
[`pubspec.yaml`](../../pubspec.yaml) and are **not** loaded by the app.

The live tree UI uses a conceptual growth map
([`GrowthMapWidget`](../../lib/src/features/dashboard/widgets/growth_map/growth_map_widget.dart))
plus seasonal overlays, not static stage images.

## Policy

- **Do not** re-add `assets/trees/` to `pubspec.yaml` unless product decides to
  restore image-based skins end-to-end.
- Keeping files in git is optional historical reference; they currently count as
  **dead assets** for the Flutter build (not bundled).
- Safe to delete from the repo in a dedicated cleanup PR if storage size matters.

See Phase 4 in the implementation plan and [PRIVACY_THREAT_MODEL.md](../../../docs/PRIVACY_THREAT_MODEL.md).
