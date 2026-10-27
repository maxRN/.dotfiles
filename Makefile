# Profiles: shredder, ohnezahn (laptop) and ohnezahn-server.
#
# Both ohnezahn profiles run on the same hostname, so the default is the profile
# that is active now (/etc/ohnezahn/profile, written by modules/server.nix), not
# the hostname alone. A bare `darwin-rebuild switch --flake .` would pick
# #ohnezahn and silently leave server mode.
#
#   make build                         # build the active profile
#   make switch PROFILE=ohnezahn-server
#   make update INPUT=pkgs-unstable    # all inputs if INPUT is empty

HOST := $(shell hostname -s)
ACTIVE := $(shell cat /etc/ohnezahn/profile 2>/dev/null)
PROFILE ?= $(if $(filter ohnezahn,$(HOST)),$(if $(filter server,$(ACTIVE)),ohnezahn-server,ohnezahn),$(HOST))
INPUT ?=

.PHONY: profile build check switch update fmt lint

profile:
	@echo "profile: $(PROFILE)"

build: profile
	nix build --no-link --no-write-lock-file --print-out-paths .#darwinConfigurations.$(PROFILE).system

# Builds every profile (they are exposed as checks.aarch64-darwin).
check:
	nix flake check --no-write-lock-file

switch: profile
	sudo darwin-rebuild switch --flake .#$(PROFILE)

update:
	nix flake update $(INPUT)

fmt:
	nix fmt

lint:
	nix run --inputs-from . nixpkgs#statix -- check .
	nix run --inputs-from . nixpkgs#deadnix -- --fail .
