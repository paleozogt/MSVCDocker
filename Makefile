MSVC_VERS = 15 14 12 11 10
WINE_VER = 4.0

buildwine: Dockerfile
	docker build --target winebase -t wine:$(WINE_VER) --build-arg WINE_VER=$(WINE_VER) .

define build-targets
  vagrantsetup$1: Vagrantfile setupbasebox
		FIRSTBOOT=1 vagrant up win-msvc$1
		vagrant halt win-msvc$1

  buildsnapshot$1: Vagrantfile
		vagrant up --provision win-msvc$1
		vagrant halt win-msvc$1

  snapshot$1: vagrantsetup$1 buildsnapshot$1

  buildimage$1: Dockerfile
		docker build -f Dockerfile -t msvc:$1 --build-arg WINE_VER=$(WINE_VER) --build-arg MSVC=$1 .

  msvc$1: snapshot$1 buildimage$1
endef

$(foreach element,$(MSVC_VERS),$(eval $(call build-targets,$(element))))

setupbasebox: ./vagranttools/setupbasebox.sh
	./vagranttools/setupbasebox.sh
