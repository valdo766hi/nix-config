{
  lib,
  pkgs,
  ...
}: {
  # Summarize what each switch added, removed or upgraded.
  home.activation.changesReport = lib.hm.dag.entryAnywhere ''
    if [[ -v oldGenPath && "$oldGenPath" != "$newGenPath" ]]; then
      ${lib.getExe pkgs.dix} diff "$oldGenPath" "$newGenPath" || true
    fi
  '';
}
