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
}
