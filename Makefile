.PHONY: work mbp

spren:
	darwin-rebuild switch --flake .#spren

mbp:
	darwin-rebuild switch --flake .#mbp
