# Repo-owned packages live under `local` so they never shadow nixpkgs names:
# nixpkgs has its own `rtk` and an unrelated `pig` (Apache Pig).
{inputs}: final: _prev: {
  local = {
    pig = final.callPackage ../pkgs/pig {};
    plannotator = final.callPackage ../pkgs/plannotator {};
    rtk = final.callPackage ../pkgs/rtk {};
  };

  llm-agents = inputs.llm-agents.packages.${final.stdenv.hostPlatform.system};
}
