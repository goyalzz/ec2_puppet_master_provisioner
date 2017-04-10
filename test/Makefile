build:
	docker build -t opstree/terraformtester .

run:
	docker run --privileged -it --rm -v ${PWD}/..:/root/terraform -e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) -e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) opstree/terraformtester  /bin/bash
