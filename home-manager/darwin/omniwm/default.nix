{
  lib,
  pkgs,
  ...
}: {
  home.activation.omniwmSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
    settings_dir="$HOME/.config/omniwm"
    ${pkgs.coreutils}/bin/mkdir -p "$settings_dir/shell"
    for name in settings.toml shell/shell.toml; do
      settings_file="$settings_dir/$name"
      settings_tmp="$settings_file.nix-tmp"
      ${pkgs.coreutils}/bin/install -m 600 ${./.}/"$name" "$settings_tmp"
      ${pkgs.coreutils}/bin/mv -f "$settings_tmp" "$settings_file"
    done

    /usr/bin/defaults write -g NSConvolutionOverride1 -float 8.0
    /usr/bin/defaults write -g NSConvolutionOverride2 -float 8.0
  '';
}
