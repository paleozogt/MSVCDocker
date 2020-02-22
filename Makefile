MSVC_VERS = 16 15 14 12 11 10 9
WINE_VER = 4.0
DOCKERCMD = docker
VAGRANTCMD = vagrant
VAGRANTARGS = 

define build-targets
  buildsnapshot$1: Vagrantfile setupbasebox
		$(VAGRANTCMD) up $(VAGRANTARGS) --provision win-msvc$1
		$(VAGRANTCMD) halt win-msvc$1

  buildmsvc$1: Dockerfile dockercheck
		$(DOCKERCMD) build -f Dockerfile -t msvc:$1 --build-arg WINE_VER=$(WINE_VER) --build-arg MSVC=$1 .

  msvc$1: dockercheck buildsnapshot$1 buildwine buildmsvc$1
endef

$(foreach element,$(MSVC_VERS),$(eval $(call build-targets,$(element))))

.PHONY: clean dockercheck

clean:
	rm -rf build/msvc*
	$(VAGRANTCMD) destroy --force || true
	$(VAGRANTCMD) global-status --prune || true
	VBoxManage list vms || true

dockercheck:
	$(DOCKERCMD) images

setupbasebox: ./vagranttools/setupbasebox.sh
	./vagranttools/setupbasebox.sh

buildwine: Dockerfile.wine dockercheck
	$(DOCKERCMD) build -f Dockerfile.wine -t wine:$(WINE_VER) --build-arg WINE_VER=$(WINE_VER) .
