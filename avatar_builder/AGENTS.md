# Agent Rules

- **Commit Policy**: You must fully test all code before committing. Do not commit changes automatically. Wait for the user to review and ask for a commit.
- **Code Style**: Prefer modern Dart syntax.
- **Testing**: Code should be designed to be testable (dependency injection, pure functions where possible).
- **Git**: Prefer `git add [file]` over `git add .` to ensure atomic and precise commits. Never run a command that wipes out uncommitted work. No `git reset --hard` unless explicitly asked.
- **Pre-commit**: Before every `git commit`, run `pre-commit run` (without `--all-files`) so hooks only process staged files. Re-stage any files modified by the hooks, then commit. This avoids failed commits from hook violations.
- **File Safety**: DO NOT forcefully delete files (e.g. `rm -f`, `git rm -f`). If a file is in the way or causing issues, ask the user or use safer alternatives (e.g. moving/renaming or unstaging).
- **Test Naming**: Tests for a file `name.dart` should be named `name_test.dart` and located in the corresponding directory in `test/`.
- **Generated Code**: `lib/svg/svg_data.dart` is generated — do not edit it manually. Use `make generate` to regenerate.

## Publishing

This is a Dart workspace monorepo with two publishable packages:

- **`avatar_builder_core`** — pure Dart, no Flutter dependency
- **`avatar_builder`** — Flutter widgets, depends on `avatar_builder_core`

### Symlinked files

Before editing CHANGELOGs or READMEs, check the git history and file structure:

```bash
ls -la avatar_builder/CHANGELOG.md avatar_builder/README.md avatar_builder_core/CHANGELOG.md
```

Several files are **symlinks to the root**:

| File | Target |
|------|--------|
| `avatar_builder/CHANGELOG.md` | `../CHANGELOG.md` |
| `avatar_builder/README.md` | `../README.md` |
| `avatar_builder_core/CHANGELOG.md` | `../CHANGELOG.md` |

This means all three packages share **one** CHANGELOG and the root/avatar_builder share **one** README. The `avatar_builder_core/README.md` is a **separate real file** with its own content.

When editing, be aware that changes to any symlinked file affect all packages that link to it. Do not write package-specific changelog entries — write a single combined entry in the root `CHANGELOG.md`.

### Version bumping checklist

1. Bump `version:` in `avatar_builder_core/pubspec.yaml`.
2. Bump `version:` in `avatar_builder/pubspec.yaml`.
3. Update the `avatar_builder_core` dependency version in `avatar_builder/pubspec.yaml`.
4. Update version references in READMEs (e.g. `^0.2.0` → `^0.3.0` in `dependencies:` snippets).
5. Add a changelog entry to the root `CHANGELOG.md` (covers all three symlinked locations).
6. Run `dart pub get` to update lockfiles.

### Publishing order

`avatar_builder_core` **must** be published first because `avatar_builder` depends on it:

```bash
cd avatar_builder_core && dart pub publish --force
cd ../avatar_builder && dart pub publish --force
```

Use `dart pub publish --dry-run` first to verify each package has no warnings.

### Pre-publish checks

Before publishing, always:

1. Run all tests: `make test` (or individually: `make test-core`, `make test-flutter`, `make test-cli`).
2. Run analyzers: `make analyze`.
3. Run `pre-commit run` on staged files.
4. Verify `dart pub publish --dry-run` for both packages.
5. Commit and push before publishing so the published code matches the repo.
