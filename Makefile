# This makes sure the commands are run within a BASH shell.
SHELL := /bin/bash

# The .PHONY target will ignore any file that exists with the same name as the target
# in your makefile, and built it regardless.
.PHONY: all clean minikube

# The all target is the default target when make is called without any arguments.
all: clean | minikube

clean:
	kubectl delete -f manifests/minikube

	# These finalizers are added, because many times the PV/PVC stays
	# in terminating mode when deleted. In this case, a new PV/PVC with
	# the same name cannot be created (since it already exists).
	# Removing finalizers does not wait for the PV/PVC to be deleted,
	# and you can create a new PV/PVC with the same name.
	- kubectl patch pv postgres-pv -p '{"metadata": {"finalizers": null}}'
	- kubectl patch pv postgres-pvc -p '{"metadata": {"finalizers": null}}'

minikube:
	echo "Start creating deployments on minikube ..."
	docker pull alpine:latest
	# docker pull nats:latest
	docker build -t nats:my -f ./Dockerfile_nats .
	docker pull postgres:latest
	
	kubectl apply -f manifests/minikube
