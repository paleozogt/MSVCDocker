MSVC_VERS = 16 15 14 12 11 10 9

define build-targets
  windev$1: Dockerfile
		docker build -f Dockerfile -t windev:$1 --build-arg MSVC=$1 .
endef

$(foreach element,$(MSVC_VERS),$(eval $(call build-targets,$(element))))
