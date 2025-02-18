{ config, lib, pkgs, ... }:

{
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.KbdInteractiveAuthentication = false;

  users.users.mathematician314 = {
    uid = 1000;
    isNormalUser = true;
    description = "mathematician314";
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPassword =
      "$6$rounds=65536$52ozQfxuGrmWZoNo$P8rggZJwwVLeShjLdNciD.EYmsHJ3N2W82drhToZnmzdl7PXC9JzpRzEHbrr6v.6/m8VQl4erGxmSvJ6aZG0T/";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCr0l1uayq1GK/3xbEZw2I6dPkXYdH1Lq2+ZIZnHEgt1XkrKdyW0vFFKtevW+0eAJ5MIW6mvH7B+hcjyBrwKGxyKMZD3C3kNKaQw7VmlCNlgs6Njpobs54b3srbytKFMyReD5ydP02SU8Vb3dxD0ZTZYUUH0t+asZZmToQgEIP+m9F/4PgFU6eYRz437OOfh/bO2tYEjNwIUAqzK6lIjy2DNclIKlZ8cL2wh+sOUsNahp6cRniAs7BhjAWxD+DgVSK7NKLexM0LMlWRv8NKnuphdDmvOYrVvLCpaOD7JeJsVar18gB9RqfcPLP2R4rGPk3gcuiyE4mabIFTkXWCD1i7"
    ];
  };
}
