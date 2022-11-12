apply: apply-main

apply-main:
	docker run -it --rm $(DEFAULT_ARGS) $(DOCKER_IMAGE):$(TF_VER) terragrunt apply $(tf_args)

plan:
	docker run -it --rm $(DEFAULT_ARGS) $(DOCKER_IMAGE):$(TF_VER) terragrunt plan $(tf_args)

destroy:
	docker run -it --rm $(DEFAULT_ARGS) $(DOCKER_IMAGE):$(TF_VER) terragrunt destroy $(tf_args)
