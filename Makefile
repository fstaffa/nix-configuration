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

switch.linux:
	sudo nixos-rebuild switch --flake "."
	home-manager switch --flake "."

# end
