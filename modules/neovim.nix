{ inputs, ... }:
{
  imports = [
    inputs.nixvim.nixosModules.nixvim
  ];
  programs.nixvim = {
    enable = true;

    opts = {
      relativenumber = true;
      number = true;
      whichwrap = "<,>,[,]";
    };

    colorschemes.catppuccin.enable = true;
    plugins = {
      lualine.enable = true;
      opencode.enable = true;
      snacks = {
        enable = true;
        settings.input.enable = true;
      };
      oil.enable = true;
      lsp = {
        enable = true;
        servers = {
          "*" = {
            config = {
              capabilities = {
                textDocument = {
                  semanticTokens = {
                    multilineTokenSupport = true;
                  };
                };
              };
              root_markers = [
                ".git"
              ];
            };
          };
          clangd = {
            config = {
              cmd = [
                "clangd"
                "--background-index"
              ];
              filetypes = [
                "c"
                "cpp"
              ];
              root_markers = [
                "compile_commands.json"
                "compile_flags.txt"
              ];
            };
            enable = true;
          };

          luau_lsp = {
            enable = true;
          };

          pyrefly = {
            enable = true;
          };

          rust_analyzer = {
            enable = true;
            installRustc = false;
            installCargo = false;
            config = {
              checkOnSave = true;
              check = {
                command = "clippy";
              };
              procMacro = {
                enable = true;
              };
            };
          };
        };
      };
    };
  };
}
