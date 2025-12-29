.PHONY: run build install clean analyze test

# Default PocketBase URL for local development
POCKETBASE_URL ?= http://10.0.2.2:8090

run:
ifndef GOOGLE_CLIENT_ID
	$(error GOOGLE_CLIENT_ID is not set. Please set it in your environment or .env file)
endif
	flutter run \
		--dart-define=POCKETBASE_URL=$(POCKETBASE_URL) \
		--dart-define=GOOGLE_SERVER_CLIENT_ID=$(GOOGLE_CLIENT_ID)

build:
ifndef GOOGLE_CLIENT_ID
	$(error GOOGLE_CLIENT_ID is not set. Please set it in your environment or .env file)
endif
	flutter build apk \
		--dart-define=POCKETBASE_URL=$(POCKETBASE_URL) \
		--dart-define=GOOGLE_SERVER_CLIENT_ID=$(GOOGLE_CLIENT_ID)

install: build
	adb install -r build/app/outputs/flutter-apk/app-release.apk

clean:
	flutter clean
	cd android && ./gradlew clean

analyze:
	flutter analyze

test:
	flutter test
