UID:=$(shell id -u)
ifeq ($(UID),0)
UID:=1000
endif
DOCKER_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PROJECT_DIR:=$(shell dirname ${DOCKER_DIR})
NVIDIA_GPU:=$(shell (docker info 2>/dev/null | grep Runtimes | grep -q nvidia && command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi >/dev/null 2>&1) && echo '--runtime nvidia --gpus all' || echo '')
XAUTH_MOUNT:=$(shell [ -f $(HOME)/.Xauthority ] && echo "-v $(HOME)/.Xauthority:/ulstu/.host/.Xauthority:ro" || echo '')
DRI_MOUNT:=$(shell [ -d /dev/dri ] && echo '-v /dev/dri:/dev/dri:ro' || echo '')
IMAGE=ulstu

FLAVOR?=devel
ROBOT_PANEL_PORT?=8008
VS_PORT?=31415
WEBOTS_STREAM_PORT?=1234

.PHONY: all allmac build run copy-working-folders copy-working-files start-code-server stop-code-server exec destroy setup-default

all: copy-working-folders run copy-working-files start-code-server
allmac: copy-working-folders run copy-working-files start-code-server

build:
	DOCKER_BUILDKIT=1 docker build $(PROJECT_DIR) -f $(DOCKER_DIR)/Dockerfile.base -t $(IMAGE) --build-arg UID=$(UID)

run:
	docker run \
		--ipc=host \
		--cap-add SYS_ADMIN \
		--name ulstu-$(FLAVOR) \
		--privileged \
		--restart unless-stopped \
		-p $(ROBOT_PANEL_PORT):8008 \
		-p $(VS_PORT):31415 \
		-p $(WEBOTS_STREAM_PORT):1234 \
		-e NVIDIA_DRIVER_CAPABILITIES=all $(NVIDIA_GPU) \
		-e DISPLAY=$(DISPLAY) \
		$(XAUTH_MOUNT) \
		-v /tmp/.X11-unix/:/tmp/.X11-unix:rw \
		$(DRI_MOUNT) \
		-v /dev:/dev:rw \
		-v $(PROJECT_DIR)/docker/projects/$(FLAVOR):/ulstu/repositories:rw \
		-d -it $(IMAGE)

copy-working-files:
	docker exec ulstu-$(FLAVOR) bash -c 'ln -sfn /ulstu/repositories/webots_ros2_suv /ulstu/ros2_ws/src/webots_ros2_suv && ln -sfn /ulstu/repositories/robot_interfaces /ulstu/ros2_ws/src/robot_interfaces'

copy-working-folders:
	if [ -d $(PROJECT_DIR)/docker/projects/$(FLAVOR) ]; then \
		echo "project dir exists. Remove it first: rm -rf $(PROJECT_DIR)/docker/projects/$(FLAVOR)"; \
		exit 1; \
	fi
	mkdir -p $(PROJECT_DIR)/docker/projects/$(FLAVOR)
	cp -a $(PROJECT_DIR)/webots_ros2_suv $(PROJECT_DIR)/docker/projects/$(FLAVOR)/webots_ros2_suv
	cp -a $(PROJECT_DIR)/robot_interfaces $(PROJECT_DIR)/docker/projects/$(FLAVOR)/robot_interfaces

start-code-server:
	docker exec -d ulstu-$(FLAVOR) bash -c 'pgrep -x code-server >/dev/null || code-server /ulstu/ros2_ws'
	@echo "Контейнер: ulstu-$(FLAVOR)"
	@echo "Терминал:  docker exec -it ulstu-$(FLAVOR) bash"
	@echo "VS Code:   http://localhost:$(VS_PORT)"
	@echo "Webots:    http://localhost:$(WEBOTS_STREAM_PORT)"
	@echo "Панель:    http://localhost:$(ROBOT_PANEL_PORT)"

stop-code-server:
	docker exec ulstu-$(FLAVOR) pkill -f code-server || true

exec:
	docker exec -it ulstu-$(FLAVOR) bash

destroy:
	docker container kill ulstu-$(FLAVOR) >/dev/null 2>&1 || true
	docker container rm -f ulstu-$(FLAVOR) >/dev/null 2>&1 || true
	rm -rf $(PROJECT_DIR)/docker/projects/$(FLAVOR)

setup-default:
	docker exec -it ulstu-$(FLAVOR) bash -lc '/usr/bin/setup.sh --first-time-ros-setup'
