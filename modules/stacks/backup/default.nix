{
  lib,
  config,
  username,
  ...
}:
let
  cfg = config.stacks.backup;

  # The other half of this (the directories and authorized keys on nuc-0, and
  # the encrypted secrets themselves) lives in the homelab and key-safe repos.
  # See homelab/docs/backup/adding-a-client.md before adding or renaming a host.

  # basic information for the target backup server
  backupUser = "dave";
  backupHost = "nuc-0";
  backupBasePath = "/backups/restic";
  repository = "sftp:${backupUser}@${backupHost}:${backupBasePath}/${config.networking.hostName}";

  # this host's secrets in key-safe, decrypted by sops-nix at login. Only
  # the paths are used here, so the plaintext never reaches the nix store.
  passwordSecret = "hosts/${config.networking.hostName}/restic-password";
  sshKeySecret = "hosts/${config.networking.hostName}/restic-ssh-key";
  hmSecrets = config.home-manager.users.${username}.sops.secrets;
  passwordFile = hmSecrets.${passwordSecret}.path;
  sshKeyFile = hmSecrets.${sshKeySecret}.path;
in
{
  options.stacks.backup = {
    enable = lib.mkEnableOption "restic based backups to nuc-0";

    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "paths to back up";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${username} = {
      sops.secrets = {
        ${passwordSecret} = { };
        ${sshKeySecret} = { };
      };

      # set the nushell environment variables so that we do not need to
      # constantly tell restic the auth data
      programs.nushell.environmentVariables = {
        RESTIC_REPOSITORY = repository;
        RESTIC_PASSWORD_FILE = passwordFile;
      };
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
