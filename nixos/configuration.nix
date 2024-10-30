# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, meta, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
    ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = meta.hostname; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Australia/Brisbane";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    #useXkbConfig = true; # use xkb.options in tty.
  };

  # Fixes for longhorn
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
  ];
  virtualisation.docker.logDriver = "json-file";

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";
  services.k3s = {
    enable = true;
    role = "server";
    token = "super-secret-token";
    #tokenFile = /var/lib/rancher/k3s/server/token;
    extraFlags = toString ([
	    "--write-kubeconfig-mode \"0644\""
	    "--cluster-init"
	    "--disable servicelb"
	    "--disable traefik"
	    "--disable local-storage"
    ] ++ (if meta.hostname == "homelab-nix-k3s-1" then [] else [
	      "--server https://homelab-nix-k3s-1:6443"
    ]));
    clusterInit = (meta.hostname == "homelab-nix-k3s-1");
  };

  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:${meta.hostname}";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.k3s = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    # Created using mkpasswd
    hashedPassword = "$6$14bmjnEHrp9GSa6M$hi/waJQMmHkzypG9m0iL8JT7cb73fdi0l0Z0OFStEypyObiAvRp5i3GKvcwgTK5b2cMXEZ04P2lcfR/IU9kNc0";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDq0hmynF4veEAYnYDOWByf6mP1WLQpY+1LM6fCoSJAUSrOyIkYJgG6iM/+JnbKytQLlwjBoZZ/eWBfFhOHw26VG9JfsPRCPqVIY4sNdP0+H7HP5TQAvzT2rarL5R7Y0v/aqa8qzm5vKVONGMrmVZIG4EoH2yBO/mUr/zh9KXszbpdmH5YhaqlPGXk633SSsKO5SDCAi/C8dbt7iZqVBx3Rsp+xD9Ie8KVfZ+3kh0MyoT8YHh6OrxKHm4yT20ZoQwmt11rt5JcQUuBSMMoNVqZFreeQPDJFAv+XpbYRQhNnBaZX7MhfwYWqiZH8QYz9+ckItsJ91dZFk1L+0sbEpxHwaimWA3nGHET0NvgIQEyWKY+GqIEULSGABjMEqpZiLD8n1iq0uzooms/GIzOJY+uoDMfYTAY5OUN7OfgLVZUa4h6f+ZXyGhBfnPC0H397mvKVJXC9p5vs4ldav1+pQcrImFR09EimeAOXFdVFaURyBcz1ou7Q7athXwh1Z12Tjhsr3yow6ZdY5u+zwXGeWFAXM4pEQGXGEMeAq+skT8ZNXbwGyVXDuBuhTi63GhTDVRl7ZzB45t4zdRkNZI7VaNwfUzt2Rz6p/LuUc2jrklS4Tk71s3+tnjnK2ZkTe4aKSFSOO7Qiz7GOLkAumIilApnLAQE1WyEb2V164qgB/Fhjpw=="
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     neovim
     k3s
     cifs-utils
     nfs-utils
     git
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 80 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}
