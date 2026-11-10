# Publishing codelessly_api

The package is published from the repository root, under its own name. Publish
it **before** `codelessly_sdk`: the SDK depends on the API version it was built
with (`codelessly_api: ^<version>`), and that version has to be on pub.dev first.

1. Set `version:` in `pubspec.yaml` and add its entry at the top of
   `CHANGELOG.md`.
2. Check, from a clean checkout:

   ```sh
   dart pub get
   dart analyze
   dart test
   dart pub publish --dry-run   # 0 warnings
   ```

3. Commit, tag (`git tag v<version>`) and publish:

   ```sh
   dart pub publish
   ```

4. Then publish `codelessly_sdk` (its PUBLISHING.md), raising its
   `codelessly_api` constraint if it needs the new version.

`.pubignore` lists what stays out of the package: `tool/`, `docs/` (the guide
is read on GitHub, `documentation:` in the pubspec) and local state.
