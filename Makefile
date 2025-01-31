.PHONY: help ec2-exercise k8s-exercise multi-stage-build-exercise docker-network-exercise custom-docker-image-exercise

help:
	@echo "Usage: make [target]"
	@echo "Lesson1:"
	@echo "  l1-ec2-exercise"
	@echo "  l1-k8s-exercise"
	@echo "  l1-multi-stage-build-exercise"
	@echo "  l1-docker-network-exercise"
	@echo "  l1-custom-docker-image-exercise"
	@echo "  l1-docker-volumes-exercise"
	@echo "  l1-container-health-checks-exercise"
	@echo "  l1-container-resource-limits"
	@echo "  l1-docker-compose-for-multi-service-apps"
	@echo "Lesson2:"
	@echo "  l2-secure-app"
	@echo "  l2-fullstack-app"
	@echo "  l2-multi-tier-app"

l1-ec2-exercise:
	@echo "[LESSON1] Running EC2 exercises..."
	@./lesson1/ec2-exercise.sh

l1-k8s-exercise:
	@echo "[LESSON1] Running K8s exercises..."
	@./lesson1/k8s-exercise.sh

l1-multi-stage-build-exercise:
	@echo "[LESSON1] Running multi-stage-build exercise..."
	cd ./lesson1/docker-exercise/multi-stage-build && ./scripts/run.sh

l1-docker-network-exercise:
	@echo "[LESSON1] Running docker-network exercise..."
	cd ./lesson1/docker-exercise/docker-network &&./scripts/run.sh

l1-custom-docker-image-exercise:
	@echo "[LESSON1] Running custom-docker-image exercise..."
	cd ./lesson1/docker-exercise/custom-docker-image &&./scripts/run.sh

l1-docker-volumes-exercise:
	@echo "[LESSON1] Running docker-volumes exercise..."
	cd ./lesson1/docker-exercise/docker-volumes &&./scripts/run.sh

l1-container-health-checks-exercise:
	@echo "[LESSON1] Running container-health-checks exercise..."
	cd ./lesson1/docker-exercise/container-health-checks &&./scripts/run.sh

l1-container-resource-limits:
	@echo "[LESSON1] Running container-resource-limits exercise..."
	cd ./lesson1/docker-exercise/container-resource-limits && ./scripts/run.sh

l1-docker-compose-for-multi-service-apps:
	@echo "[LESSON1] Running docker-compose-for-multi-service-apps exercise..."
	cd ./lesson1/docker-exercise/docker-compose-for-multi-service-apps && ./scripts/run.sh

l2-secure-app:
	@echo "[LESSON2] Running secure-app exercise..."
	cd ./lesson2/k8_secure_scalable_exercise && ./scripts/run.sh

l2-fullstack-app:
	@echo "[LESSON2] Running fullstack-app exercise..."
	cd ./lesson2/k8s_fullStack_exercise && ./scripts/run.sh

l2-multi-tier-app:
	@echo "[LESSON2] Running multi-tier-app exercise..."
	cd ./lesson2/k8s_multi-tier_exercise && ./scripts/run.sh