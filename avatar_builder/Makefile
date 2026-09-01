.PHONY: all format analyze test test-core test-flutter test-cli test-ci test-golden test-golden-ci fix clean run generate

# Device to run on: chrome, macos, ios, android (default: chrome)
DEVICE ?= chrome

## Run all checks (format, analyze, test)
all: format analyze test

## Run the example app (use DEVICE=macos, DEVICE=ios, etc.)
run:
	cd avatar_builder/example && flutter run -d $(DEVICE)

## Format all Dart code
format:
	dart format .

## Run the analyzer
analyze:
	cd avatar_builder_core && dart analyze
	cd avatar_builder && flutter analyze
	cd avatar_builder/example && flutter analyze

## Run all tests
test: test-core test-flutter test-cli

## Run pure-Dart core tests
test-core:
	cd avatar_builder_core && dart test

## Run Flutter widget/golden tests
test-flutter:
ifeq ($(shell uname), Darwin)
	cd avatar_builder && flutter test
else
	cd avatar_builder && flutter test --exclude-tags mac
endif

## Run CLI (bin/generate.dart) tests
test-cli:
	dart test test/generate_cli_test.dart

## Run tests for CI (excludes golden/mac tests, injects build info)
test-ci:
	cd avatar_builder_core && dart test
	cd avatar_builder && flutter test --exclude-tags mac \
		--dart-define=COMMIT_HASH=$$(git rev-parse --short HEAD) \
		--dart-define=BUILD_DATE="$$(date -u +'%Y-%m-%d %H:%M UTC')"
	dart test test/generate_cli_test.dart

## Run golden tests (macOS only)
test-golden:
	cd avatar_builder && flutter test --tags mac

## Run golden tests for CI (macOS only), updating goldens
test-golden-ci:
	cd avatar_builder && flutter test --tags mac

## Apply auto-fixes
fix:
	dart fix --apply

## Delete build artifacts
clean:
	cd avatar_builder_core && rm -rf .dart_tool build
	cd avatar_builder && flutter clean
	cd avatar_builder/example && flutter clean

## Regenerate SVG data from React avataaars library
generate:
	cd avataaars-generator && NODE_PATH=./node_modules node ../tools/extract_svg_fragments.js
	python3 tools/generate_svg_data.py
	dart format avatar_builder_core/lib/src/svg/svg_data.dart
