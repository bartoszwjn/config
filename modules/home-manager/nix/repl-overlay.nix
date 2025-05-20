info: final: prev:

if prev ? legacyPackages.${info.currentSystem} then
  { pkgs = prev.legacyPackages.${info.currentSystem}; }
else
  { }
