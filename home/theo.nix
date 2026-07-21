{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  # TODO: add niri configuration: https://github.com/nix-community/home-manager/pull/8575
  home.username = "theo";
  home.homeDirectory = "/home/theo";
  home.stateVersion = lib.trivial.release;

  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
      }
      {
        profile.name = "docked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "HDMI-A-1";
            status = "enable";
          }
        ];
      }
    ];
  };

  # Based on https://github.com/thoughtpolice/a/blob/canon/tilde/aseipp/dotfiles/jj/config.toml
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Theo Paris";
        email = "theo@theoparis.com";
      };
      ui = {
        diff-formatter = "difft";
      };
      merge-tools = {
        delta = {
          diff-expected-exit-codes = [
            0
            1
          ];
        };
      };
      template-aliases = {
        "ndjson(obj)" = "json(obj) ++ \"\n\"";
        "ndjson" = "ndjson(self)";
      };
      revset-aliases = {
        at = "@";
        "user(x)" = "author(x) | committer(x)";
        "immutable_heads()" = "present(trunk()) | untracked_remote_bookmarks() | tags()";
        "wip()" = "description(glob-i:\"wip:*\") | description(glob-i:\"[[]WIP[]]*\")";
        "private()" = "description(glob-i:\"private:*\") | description(glob-i:\"[[]PRIVATE[]]*\")";
        "blacklist()" = "wip() | private()";
        "stack()" = "stack(@)";
        "stack(x)" = "stack(x, 2)";
        "stack(x, n)" = "ancestors(reachable(x, mutable()), n)";
        "open()" = "stack(mine() | @, 1) ~ hidden()";
        "ready()" = "open() ~ descendants(blacklist())";
        "megamerge()" = "coalesce(present(megamerge), reachable(stack(), merges()))";
        "uninteresting()" = "::remote_bookmarks() | tags():";
        "interesting()" = "mine() ~ uninteresting()";
      };
      aliases = {
        nt = [
          "new"
          "trunk()"
        ];
        cat = [
          "file"
          "show"
        ];
        credit = [
          "file"
          "annotate"
        ];
        streamline = [ "simplify-parents" ];
        tug = [
          "bookmark"
          "move"
          "--from"
          "heads(::@- & bookmarks())"
          "--to"
          "@-"
        ];
        open = [
          "log"
          "-r"
          "open()"
        ];
        retrunk = [
          "rebase"
          "-d"
          "trunk()"
        ];
        reheat = [
          "rebase"
          "-d"
          "trunk()"
          "-s"
          "roots(trunk()..stack(@))"
        ];
        sandwich = [
          "rebase"
          "-B"
          "megamerge()"
          "-A"
          "trunk()"
          "-r"
        ];
        consume = [
          "squash"
          "--into"
          "@"
          "--from"
        ];
        eject = [
          "squash"
          "--from"
          "@"
          "--into"
        ];
        examine = [
          "log"
          "-T"
          "builtin_log_detailed"
          "-p"
          "-r"
        ];
        jsonlog = [
          "log"
          "--no-graph"
          "-T"
          "ndjson"
        ];
      };
      gerrit = {
        default-remote = "gerrit";
        default-remote-branch = "main";
      };
      signing = {
        behavior = "own";
        backend = "ssh";
        key = "~/.ssh/id_ed25519.pub";
      };
      merge-tools.difft = {
        program = "difft";
        diff-args = [
          "--color=always"
          "$left"
          "$right"
        ];
        diff-invocation-mode = "file-by-file";
      };
      git = {
        write-change-id-header = true;
        private-commits = "blacklist()";
        sign-on-push = true;
        fetch = [
          "upstream"
          "origin"
        ];
      };
      snapshot = {
        auto-update-stale = true;
      };
      templates = {
        commit_trailers = ''
          format_signed_off_by_trailer(self)
          ++ if(!trailers.contains_key("Change-Id"), format_gerrit_change_id_trailer(self))
        '';
        git_push_bookmark = ''"theoparis/" ++ stringify(truncate_end(32, description.first_line().lower())).replace(regex:"[^a-zA-Z0-9]+", "-").replace(regex:"^-.*", "").replace(regex:"-*$", "") ++ "-" ++ change_id.short()'';
      };
    };
  };

  home.packages = with pkgs; [
    starship
    (symlinkJoin {
      name = "pi-wrapped";
      paths = [ inputs.nixpkgs-master.legacyPackages.${stdenv.hostPlatform.system}.pi-coding-agent ]; # Or whatever flake package you use
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/pi \
          --set NPM_CONFIG_PREFIX "${config.home.homeDirectory}/.pi/npm/" \
          --prefix PATH : ${lib.makeBinPath [ nodejs_latest ]}
      '';
    })
  ];

  # programs.alacritty = {
  #   enable = true;
  #   settings = {
  #     font.size = 14.0;
  #     font.normal.family = "FiraCode Nerd Font";
  #   };
  # };

  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
  };
}
