let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
in
builtins.mapAttrs (
  inputName: nodeName: builtins.fetchTree lock.nodes.${nodeName}.locked
) lock.nodes.${lock.root}.inputs
