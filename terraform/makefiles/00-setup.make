.PHONY: get init plan apply destroy
.DEFAULT_GOAL := help

DOCKER_IMAGE := interrobangc/terraform

SECRETS = -e AWS_DEFAULT_REGION -e AWS_SECRET_ACCESS_KEY -e AWS_ACCESS_KEY_ID -v ~/.aws:/root/.aws -e GITHUB_OWNER -e GITHUB_TOKEN -e TF_VAR_github_token=${GITHUB_TOKEN}
MY_PWD := $(shell cd ../../..; pwd)
MY_ENV := $(shell basename $(CURDIR))

PWD_ARG = -v $(MY_PWD):/app -w /app/terraform/environments/$(MY_ENV)
ENV_ARG = -e MY_ENV=$(MY_ENV) -e SSM_DB_SECRET_NAME=$(SSM_DB_SECRET_NAME)
NET_ARG = --network="slack-ops-aws_default"

DEFAULT_ARGS = $(SECRETS) $(PWD_ARG) $(ENV_ARG) $(NET_ARG)
