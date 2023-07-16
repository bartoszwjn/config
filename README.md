# System config

Configuration for my personal machines, using [NixOS](https://nixos.org) and
[home-manager](https://github.com/nix-community/home-manager). The goal is to easily keep the
configuration of multiple machines in sync, and to be able to quickly set up new ones.

[`flake.nix`](./flake.nix) is the root of all Nix configuration. Configurations for NixOS systems
are defined in the `nixosConfigurations` flake output, with home-manager used as a NixOS module.
