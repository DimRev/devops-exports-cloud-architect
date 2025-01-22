.PHONY: help ec2-exercise k8s-exercise multi-stage-build-exercise docker-network-exercise custom-docker-image-exercise

help:
	@echo "Usage: make [target]"
	@echo "Lesson1:"
	@echo "  ec2-exercise"
	@echo "  k8s-exercise"
	@echo "  multi-stage-build-exercise"
	@echo "  docker-network-exercise"
	@echo "  custom-docker-image-exercise"
	@echo "  docker-volumes-exercise"
	@echo "  container-health-checks-exercise"

ec2-exercise:
	@echo "Running EC2 exercises..."
	@./lesson1/ec2-exercise.sh

k8s-exercise:
	@echo "Running K8s exercises..."
	@./lesson1/k8s-exercise.sh

multi-stage-build-exercise:
	@echo "Running multi-stage-build exercise..."
	cd ./lesson1/docker-exercise/multi-stage-build && ./scripts/run.sh

docker-network-exercise:
	@echo "Running docker-network exercise..."
	cd ./lesson1/docker-exercise/docker-network &&./scripts/run.sh

custom-docker-image-exercise:
	@echo "Running custom-docker-image exercise..."
	cd ./lesson1/docker-exercise/custom-docker-image &&./scripts/run.sh

docker-volumes-exercise:
	@echo "Running docker-volumes exercise..."
	cd ./lesson1/docker-exercise/docker-volumes &&./scripts/run.sh
	
container-health-checks-exercise:
	@echo "Running container-health-checks exercise..."
	cd ./lesson1/docker-exercise/container-health-checks &&./scripts/run.sh