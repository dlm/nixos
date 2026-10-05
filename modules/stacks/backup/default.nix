{
  lib,
  config,
  username,
  ...
}:
let
  cfg = config.stacks.backup;

  # basic information for the target backup server
  backupUser = "dave";
  backupHost = "nuc-0";
  backupBasePath = "/backups/restic";
  repository = "sftp:${backupUser}@${backupHost}:${backupBasePath}/${config.networking.hostName}";

  # basic information for sops on host
  hostSopsRoot = "/home/${username}/.config/sops-nix/secrets";
  passwordFile = "${hostSopsRoot}/${cfg.passwordSopsPath}";
  sshKeyFile = "${hostSopsRoot}/${cfg.sshKeySopsPath}";
in
{
  options.stacks.backup = {
    enable = lib.mkEnableOption "restic based backups to nuc-0";

    passwordSopsPath = lib.mkOption {
      type = lib.types.str;
      description = "sops key path for the restic repository password. (e.g. hosts/petrillo/restic-password)";
    };

    sshKeySopsPath = lib.mkOption {
      type = lib.types.str;
      description = "sops key path to the SSH private key used to reach the sftp backend (e.g. hosts/petrillo/restic-ssh-key";
    };

    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "paths to back up";
    };
  };

  config = lib.mkIf cfg.enable {
    # set the nushell environment variables so that we do not need to
    # constantly tell restic the auth data
    home-manager.users.${username}.programs.nushell.environmentVariables = {
      RESTIC_REPOSITORY = repository;
      RESTIC_PASSWORD_FILE = passwordFile;
    };

    services.restic.backups.main = {
      initialize = true;
      repository = repository;
      passwordFile = passwordFile;
      user = username;
      paths = cfg.paths;

      exclude = [
        # local/dev env caches
        "**/.direnv"

        # go
        "**/pkg/mod"
        "**/.gocache"

        # rust
        "**/target"

        # python
        "**/__pycache__"
        "**/.pytest_cache"
        "**/.mypy_cache"
        "**/.ruff_cache"
        "**/.tox"
        "**/.venv"
        "**/venv"

        # js, ts, node, etc
        "**/node_modules"
        "**/.next"
        "**/.nuxt"
        "**/dist"
        "**/build"
        "**/coverage"

        # general editor/tool junk
        "**/.DS_Store"
        "**/.idea"
        "**/.vscode"

        # your temp / restore areas
        "/home/${username}/tmp"
        "/home/${username}/.cache"
      ];

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];

      extraOptions = [
        "sftp.command='${
          lib.concatStringsSep " " [
            "ssh"
            "-o StrictHostKeyChecking=accept-new"
            "${backupUser}@${backupHost}"
            "-i ${sshKeyFile}"
            "-s sftp"
          ]
        }'"
      ];

      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "30m";
      };
    };
  };
}
