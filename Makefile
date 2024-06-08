include secrets.mk

.PHONY: clean

# For packages/hello
# SERVER_DIR = packages/hello
# FUNCTION_TARGET = hello
# FUNCTION_SIGNATURE_TYPE = http

# For packages/hello_server
# SERVER_DIR = packages/hello_server
# FUNCTION_TARGET = hello
# FUNCTION_SIGNATURE_TYPE = cloudevent

# For packages/server
SERVER_DIR = packages/server
FUNCTION_TARGET = oncreateparticipant
FUNCTION_SIGNATURE_TYPE = cloudevent
EVENT_TYPE = google.cloud.firestore.document.v1.created
PATH_PATTERN = participants/{participantId}

REGION = asia-northeast1
MAX_INSTANCE_LIMIT = 1
MEMORY_LIMIT = 256Mi

build:
	cd $(SERVER_DIR) && dart run build_runner build -d

clean:
	cd $(SERVER_DIR) && dart run build_runner clean

compile: build
	cd $(SERVER_DIR) && dart compile exe bin/server.dart -o bin/server

run: build
	cd $(SERVER_DIR) && dart run bin/server.dart --target=$(FUNCTION_TARGET) --signature-type=$(FUNCTION_SIGNATURE_TYPE)

# https://cloud.google.com/sdk/gcloud/reference/run/deploy
# https://cloud.google.com/functions/docs/configuring/max-instances
# https://cloud.google.com/functions/docs/configuring/memory
deploy-function: build
	gcloud run deploy $(FUNCTION_TARGET) \
		--source=$(SERVER_DIR) \
		--region=$(REGION) \
		--project=$(PROJECT_ID) \
		--no-allow-unauthenticated \
		--max-instances $(MAX_INSTANCE_LIMIT) \
		--memory=$(MEMORY_LIMIT) \
		--set-env-vars=ENVIRONMENT=production \
		--set-secrets=PROJECT_ID=PROJECT_ID:latest,CLIENT_ID=CLIENT_ID:latest,CLIENT_EMAIL=CLIENT_EMAIL:latest,PRIVATE_KEY=PRIVATE_KEY:latest \
		--quiet

deploy-unauthenticated-function: build
	gcloud run deploy $(FUNCTION_TARGET) \
		--source=$(SERVER_DIR) \
		--region=$(REGION) \
		--project=$(PROJECT_ID) \
		--allow-unauthenticated \
		--max-instances $(MAX_INSTANCE_LIMIT) \
		--memory=$(MEMORY_LIMIT) \
		--set-env-vars=ENVIRONMENT=production \
		--set-secrets=PROJECT_ID=PROJECT_ID:latest,CLIENT_ID=CLIENT_ID:latest,CLIENT_EMAIL=CLIENT_EMAIL:latest,PRIVATE_KEY=PRIVATE_KEY:latest \
		--quiet

# https://cloud.google.com/sdk/gcloud/reference/run/services/list
list-services:
	gcloud run services list \
		--platform managed \
		--region=$(REGION) \
		--project=$(PROJECT_ID)

# https://cloud.google.com/sdk/gcloud/reference/run/services/delete
delete-service:
	gcloud run services delete $(FUNCTION_TARGET) \
		--platform managed \
		--region=$(REGION) \
		--project=$(PROJECT_ID) \
		--quiet

# https://cloud.google.com/sdk/gcloud/reference/eventarc/triggers/create
# https://cloud.google.com/eventarc/docs/run/route-trigger-eventarc
# https://cloud.google.com/eventarc/docs/run/route-trigger-cloud-firestore
deploy-trigger:
	gcloud eventarc triggers create $(FUNCTION_TARGET) \
    --location=$(REGION) \
    --destination-run-service=$(FUNCTION_TARGET) \
    --event-filters="type=$(EVENT_TYPE)" \
    --event-filters="database=(default)" \
    --event-filters="namespace=(default)" \
    --event-filters-path-pattern="document=$(PATH_PATTERN)" \
    --event-data-content-type="application/protobuf" \
    --service-account="$(EVENT_ARC_SERVICE_ACCOUNT_NAME)@$(PROJECT_ID).iam.gserviceaccount.com" \
		--project=$(PROJECT_ID)

# https://cloud.google.com/sdk/gcloud/reference/eventarc/triggers/describe
check-trigger:
	gcloud eventarc triggers describe $(FUNCTION_TARGET) \
		--location=$(REGION) \
		--project=$(PROJECT_ID)

# https://cloud.google.com/sdk/gcloud/reference/eventarc/triggers/delete
delete-trigger:
	gcloud eventarc triggers delete $(FUNCTION_TARGET) \
		--location=$(REGION) \
		--project=$(PROJECT_ID)
		--quiet

delete: delete-trigger delete-service
