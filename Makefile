.PHONY: hooks project format format-check format-version build build-release test-unit record-snapshots test-snapshots test-design-system record-design-system-snapshots test-api test

SCHEME ?= TemplateIOS
SIMULATOR ?= iPhone 17 Pro Max
DESTINATION ?= platform=iOS Simulator,id=$(shell ./scripts/resolve-simulator.sh "$(SIMULATOR)")
CONFIGURATION ?= Debug
DERIVED_DATA ?= .build/derivedData
SWIFTFORMAT_VERSION ?= 0.62.1
SNAPSHOT_PATH ?=
SNAPSHOT_FILTER = $(if $(SNAPSHOT_PATH),/$(SNAPSHOT_PATH),)
DESIGN_SYSTEM_FILTER = $(if $(SNAPSHOT_PATH),-only-testing:DesignSystemSnapshotTests/$(SNAPSHOT_PATH),)
RECORDING = TEST_RUNNER_SNAPSHOT_RECORD=1
# The references are en_GB's — CoreText grows the line box for a preferred language with taller glyphs.
TEST = test -testLanguage en -testRegion GB
# Nothing outside Xcode reads the index store.
NO_INDEX_STORE = COMPILER_INDEX_STORE_ENABLE=NO
XCODEBUILD = xcodebuild -project TemplateIOS.xcodeproj -scheme $(SCHEME) -destination "$(DESTINATION)" -configuration $(CONFIGURATION) -derivedDataPath $(DERIVED_DATA) $(NO_INDEX_STORE)
DESIGN_SYSTEM_XCODEBUILD = xcodebuild -scheme DesignSystem -destination "$(DESTINATION)" -derivedDataPath ../../$(DERIVED_DATA) $(NO_INDEX_STORE)
API_XCODEBUILD = xcodebuild -scheme TemplateAPI -destination "platform=macOS" -derivedDataPath ../../$(DERIVED_DATA) $(NO_INDEX_STORE)

hooks:
	git config core.hooksPath .githooks

project:
	xcodegen generate

format-version:
	@installed="$$(swiftformat --version 2>/dev/null || echo missing)"; \
	[ "$$installed" = "$(SWIFTFORMAT_VERSION)" ] || { \
		echo "SwiftFormat $(SWIFTFORMAT_VERSION) is required, found $$installed — brew install swiftformat, or pass SWIFTFORMAT_VERSION=$$installed to use that one deliberately" >&2; \
		exit 1; \
	}

format: format-version
	swiftformat .

format-check: format-version
	swiftformat --lint .

build: project
	$(XCODEBUILD) build

build-release: CONFIGURATION = Release
build-release: DESTINATION = generic/platform=iOS
build-release: project
	$(XCODEBUILD) build CODE_SIGNING_ALLOWED=NO

test-unit: project
	$(XCODEBUILD) $(TEST) -only-testing:UnitTests

record-snapshots: project
	@$(RECORDING) $(XCODEBUILD) $(TEST) -collect-test-diagnostics never -only-testing:SnapshotTests$(SNAPSHOT_FILTER) || true
	@echo "recorded — a recording run fails by design; make test-snapshots verifies" >&2

test-snapshots: project
	$(XCODEBUILD) $(TEST) -only-testing:SnapshotTests$(SNAPSHOT_FILTER)

test-design-system:
	cd Packages/DesignSystem && $(DESIGN_SYSTEM_XCODEBUILD) $(TEST) $(DESIGN_SYSTEM_FILTER)

record-design-system-snapshots:
	@cd Packages/DesignSystem && $(RECORDING) $(DESIGN_SYSTEM_XCODEBUILD) $(TEST) -collect-test-diagnostics never $(DESIGN_SYSTEM_FILTER) || true
	@echo "recorded — a recording run fails by design; make test-design-system verifies" >&2

test-api:
	cd Packages/TemplateAPI && $(API_XCODEBUILD) test

test: test-design-system test-api test-unit test-snapshots
