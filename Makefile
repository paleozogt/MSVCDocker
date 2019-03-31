MSVC_VERS = 15 14 12 11 10 9
WINE_VER = 4.0
DOCKERCMD = docker
VAGRANTCMD = vagrant
VAGRANTARGS = 

buildwine: Dockerfile
	$(DOCKERCMD) build --target winebase -t wine:$(WINE_VER) --build-arg WINE_VER=$(WINE_VER) .

define build-targets
  vagrantsetup$1: Vagrantfile setupbasebox
		FIRSTBOOT=1 $(VAGRANTCMD) up $(VAGRANTARGS) win-msvc$1
		vagrant halt win-msvc$1

  buildsnapshot$1: Vagrantfile
		$(VAGRANTCMD) up $(VAGRANTARGS) --provision win-msvc$1
		$(VAGRANTCMD) halt win-msvc$1

  snapshot$1: vagrantsetup$1 buildsnapshot$1

  buildimage$1: Dockerfile
		$(DOCKERCMD) build -f Dockerfile -t msvc:$1 --build-arg WINE_VER=$(WINE_VER) --build-arg MSVC=$1 .

  msvc$1: snapshot$1 buildimage$1
endef

$(foreach element,$(MSVC_VERS),$(eval $(call build-targets,$(element))))

setupbasebox: ./vagranttools/setupbasebox.sh
	./vagranttools/setupbasebox.sh
