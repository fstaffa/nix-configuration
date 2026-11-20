##
# Project Title
#
# @file
# @version 0.1
update:
	echo "Updating project dependencies..."
	nix flake update

test.nixos:
	nixos-rebuild build --flake "."

test.homemanager:
	home-manager build --flake "."

test.update: update test.homemanager test.nixos
	echo "All tests passed successfully."

check.nixlock:
	@sudo flock -E 75 -w 10 -x /nix/var/nix/db/big-lock true; rc=$$?; [ $$rc -eq 0 ] && exit 0; [ $$rc -ne 75 ] && exit $$rc; { \
	  echo "ERROR: nix store lock held >10s (usually nixd-attrset-eval). Holders:"; \
	  ps -eo pid,etime,args | grep -E 'nixd|nix-daemon [0-9]' | grep -v grep; \
	  echo "Fix: pkill nixd"; exit 1; }

switch.linux: check.nixlock
	sudo nixos-rebuild switch --flake "."
	home-manager switch --flake "."

switch.macos:
	home-manager switch --flake "."
	sudo darwin-rebuild switch --flake "."

# end
