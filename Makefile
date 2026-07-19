PROJECT := MacTris.xcodeproj
SCHEME := MacTris

.PHONY: build test lint clean

build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration Debug build

test:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration "Debug Test" test -only-testing:MacTrisTests

test-%:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration "Debug Test" test -only-testing:MacTrisTests/$*

lint:
	swiftlint

clean:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) clean
