apply: apply-tg

init: init-tg

apply-tg:
	docker run -it --rm $(DEFAULT_ARGS) $(DOCKER_IMAGE):$(TF_VER) terragrunt apply $(tf_args)

init-tg:
	docker run -it --rm $(DEFAULT_ARGS) $(DOCKER_IMAGE):$(TF_VER) terragrunt init $(tf_args)

plan-tg:
	docker run -it --rm $(DEFAULT_ARGS) $(DOCKER_IMAGE):$(TF_VER) terragrunt plan $(tf_args)

destroy-tg:
	docker run -it --rm $(DEFAULT_ARGS) $(DOCKER_IMAGE):$(TF_VER) terragrunt destroy $(tf_args)
