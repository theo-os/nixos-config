{
  config,
  ...
}:
{
  # nixpkgs.hostPlatform = {
  #   system = "x86_64-linux";
  #   useLLVM = true;
  #   linker = "lld";
  # };

  nixpkgs.config.replaceStdenv =
    { pkgs }:
    pkgs.useWildLinker pkgs.stdenv;

  nixpkgs.overlays = [
    (final: previous: {
      # Without this, libev -> fetchpatch causes bootstrap issues
      nghttp2 = previous.nghttp2.override {
        enableApp = false;
      };
    })
  ];
}
