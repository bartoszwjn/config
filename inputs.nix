let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
in
assert lock.version == 7;
builtins.mapAttrs (
  inputName: nodeName: builtins.fetchTree lock.nodes.${nodeName}.locked
) lock.nodes.${lock.root}.inputs
