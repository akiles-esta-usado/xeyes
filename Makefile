all: print

DOCKER_IMAGE_TAG=akilesalreadytaken/xeyes:latest
STAGE=xeyes

# Windows Specific Configuration
################################
ifeq (Windows_NT,$(OS))

USER_ID=1000
USER_GROUP=1000
DOCKER_RUN=docker run -it $(_DOCKER_ROOT_USER) \
	--user $(USER_ID):$(USER_GROUP) \
	-e SHELL=/bin/bash \
	-e DISPLAY=host.docker.internal:0 \
	-e LIBGL_ALWAYS_INDIRECT=1 \
	-e XDG_RUNTIME_DIR \
	-e PULSE_SERVER

_XSERVER_EXISTS := $(shell powershell -noprofile Get-Process vcxsrv -ErrorAction SilentlyContinue)
START_XSERVER   := powershell -noprofile vcxsrv.exe :0 -multiwindow -clipboard -primary -wgl

else

UNAME_S := $(shell uname -s)
USER_ID=$(shell id -u)
USER_GROUP=$(shell id -g)

# Linux Specific Configuration
##############################
ifeq (Linux,$(UNAME_S))

# Since it uses local xserver, --net=host is required and DISPLAY should be equal to host

DOCKER_RUN=docker run -it $(_DOCKER_ROOT_USER) \
	-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
	-v /home/$(USER)/.Xauthority:/root/.Xauthority:rw \
	-v /home/$(USER)/.Xauthority:/home/designer/.Xauthority:rw \
	--net=host \
	-e SHELL=/bin/bash \
	-e DISPLAY \
	-e LIBGL_ALWAYS_INDIRECT=1 \
	-e XDG_RUNTIME_DIR \
	-e PULSE_SERVER \
	-e USER_ID=$(USER_ID) \
	-e USER_GROUP=$(USER_GROUP)

# _XSERVER_EXISTS and START_XSERVER are not required

endif

# Mac Specific Configuration
############################
ifeq (Darwin,$(UNAME_S))

DOCKER_RUN=docker run -it --rm $(_DOCKER_ROOT_USER) \
	-e SHELL=/bin/bash \
	-e DISPLAY=host.docker.internal:0 \
	-e LIBGL_ALWAYS_INDIRECT=1 \
	-e XDG_RUNTIME_DIR \
	-e PULSE_SERVER \
	-e USER_ID=$(USER_ID) \
	-e USER_GROUP=$(USER_GROUP)

# _XSERVER_EXISTS:=$(shell ?)
# START_XSERVER=xquartz ... ?

endif # Linux/Mac differenciation
endif # Windows differenciation


########################
# Docker Image Commands
########################


print:
	@echo DOCKER_IMAGE_TAG ........ $(DOCKER_IMAGE_TAG)
	@echo OS ...................... $(OS)
	@echo UNAME_S ................. $(UNAME_S)
	@echo _XSERVER_EXISTS ......... $(_XSERVER_EXISTS)
	@echo DOCKER_RUN .............. $(DOCKER_RUN)


build:
	BUILDKIT_PROGRESS=plain docker build -t $(DOCKER_IMAGE_TAG) .
	docker image ls $(DOCKER_IMAGE_TAG)


xserver:
ifeq (,$(_XSERVER_EXISTS))
	$(START_XSERVER)
endif


start: xserver pull
	$(DOCKER_RUN) --rm $(DOCKER_IMAGE_TAG)


start-raw:
	docker run -it --rm $(_DOCKER_ROOT_USER) $(DOCKER_IMAGE_TAG)


push:
	docker image push $(DOCKER_IMAGE_TAG)


pull:
ifeq (,$(NO_PULL))
	docker image pull $(DOCKER_IMAGE_TAG)
endif