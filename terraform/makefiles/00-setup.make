TF_VER ?= 1.4.4

DOCKER_IMAGE := interrobangc/terraform

REPO_ROOT ?= $(shell git rev-parse --show-toplevel)
MOUNT_PATH = /app
TF_ROOT_PATH = $(MOUNT_PATH)/terraform

SECRETS = -e AWS_DEFAULT_REGION -e AWS_SECRET_ACCESS_KEY -e AWS_ACCESS_KEY_ID -v ~/.aws:/root/.aws -e GITHUB_OWNER -e GITHUB_TOKEN -e TF_VAR_github_token=${GITHUB_TOKEN}
MY_ENV := $(shell basename $(CURDIR))
MY_RELATIVE_PATH := $(shell echo $(CURDIR) | sed -e "s|$(REPO_ROOT)||")

PWD_ARG = -v $(REPO_ROOT):$(MOUNT_PATH) -w $(MOUNT_PATH)$(MY_RELATIVE_PATH)
ENV_ARG = -e MY_ENV=$(MY_ENV) -e SSM_DB_SECRET_NAME=$(SSM_DB_SECRET_NAME)
NET_ARG = --network="slack-ops-aws_default"

DEFAULT_ARGS = $(SECRETS) $(PWD_ARG) $(ENV_ARG) $(NET_ARG)
