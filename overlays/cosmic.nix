final: prev: {
  # workaround for https://github.com/pop-os/cosmic-session/issues/148
  cosmic-session = prev.cosmic-session.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace data/start-cosmic \
        --replace-fail 'export SSH_AUTH_SOCK="/run/user/$(id -u)/keyring/ssh"' ""
    '';
  });
}
