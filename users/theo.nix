{
  lib,
  ...
}:
{
  home.username = "theo";
  home.homeDirectory = "/home/theo";
  home.stateVersion = lib.trivial.release;

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Theo Paris";
        email = "theo@theoparis.com";
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
      git = {
        sign-on-push = true;
        fetch = [
          "upstream"
          "origin"
        ];
      };
      templates = {
        commit_trailers = ''
          format_signed_off_by_trailer(self)
          ++ if(!trailers.contains_key("Change-Id"), format_gerrit_change_id_trailer(self))
        '';
      };
    };
  };
}
