# System config

Configuration for my personal machines, using [Nix](https://nixos.org) and
[home-manager](https://github.com/nix-community/home-manager). The goal is to easily keep the
configuration of multiple machines in sync, and to be able to quickly set up new ones.

[`flake.nix`](./flake.nix) is the root of all Nix configuration. On NixOS systems home-manager is
used as a NixOS module, configurations for those systems are defined in the `nixosConfigurations`
flake output. Arch Linux configurations use the standalone `home-manager` command, configurations
for those are defined in the `homeConfigurations` flake output. System configuration on Arch that
cannot be done with home-manager uses the [`archman`](https://github.com/bartoszwjn/archman) tool,
which reads its configuration from [`archman.toml`](./archman.toml).
