
INSTALLCMD=packer build -var-file variables.json
LOCATION=$(shell awk -F : /LOCATION/'{print $$2}' variables.json)

bootstrap:
	az group create -l $(LOCATION) -n packertest

centos: bootstrap
	$(INSTALLCMD) centos.json

ubuntu: bootstrap
	$(INSTALLCMD) ubuntu.json

freebsd: bootstrap
	$(INSTALLCMD) freebsd.json

.DEFAULT_GOAL :=
default:
	@echo choose between centos, freebsd, ubuntu
