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
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
    };

    globals.mapleader = " ";

    keymaps = [
      {
        action = "<cmd>:lua MiniFiles.open()<CR>";
        key = "<leader>f";
        options = {
          silent = true;
        };
      }
    ];

    colorschemes.catppuccin.enable = true;
    plugins = {
      lualine.enable = true;
      codecompanion.enable = true;
      copilot-lua.enable = true;
      blink-cmp.enable = true;
      snacks = {
        enable = true;
        settings.input.enable = true;
      };
      mini-files.enable = true;
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
          nixd = {
            enable = true;
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
            installRustfmt = false;
            extraOptions = {
              settings = {
                rust-analyzer = {
                  checkOnSave = true;
                  check = {
                    command = "clippy";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
