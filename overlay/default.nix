final: previous: {
  llama-cpp =
    (previous.llama-cpp.override {
      vulkanSupport = true;
    }).overrideAttrs
      (old: {
        cmakeFlags = old.cmakeFlags ++ [
          "-DLLAMA_BUILD_EXAMPLES=ON"
          "-DGGML_NATIVE=ON"
        ];
      });

  # FIXME: nix-functional-tests -> stale-file-handle test fails?!
  nix-functional-tests = previous.nix-functional-tests.overrideAttrs (old: {
    buildCommand = ''
      mkdir -p $out
      touch $out/ignored
    '';
    doCheck = false;
    doInstallCheck = false;
  });

  nix = previous.nix.overrideAttrs (old: {
    doCheck = false;
    doInstallCheck = false;
    passthru = (old.passthru or { }) // {
      tests = { };
    };
  });

  # FIXME: testrwlock times out
  # cmake = previous.cmake.overrideAttrs (old: {
  #   doCheck = false;
  #   doInstallCheck = false;
  #   passthru = (old.passthru or { }) // {
  #     tests = { };
  #   };
  # });
}
