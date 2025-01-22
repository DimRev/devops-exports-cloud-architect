.PHONY: ec2-exercise k8s-exercise multi-stage-build-exercise

ec2-exercise:
	@echo "Running EC2 exercises..."
	@./lesson1/ec2-exercise.sh

k8s-exercise:
	@echo "Running K8s exercises..."
	@./lesson1/k8s-exercise.sh

multi-stage-build-exercise:
	@echo "Running multi-stage-build exercise..."
	cd ./lesson1/docker-exercise/multi-stage-build && ./scripts/run.sh
