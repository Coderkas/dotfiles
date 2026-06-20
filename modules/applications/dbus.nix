{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.dbus;
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    mkMerge
    types
    ;

  makeDBusPaths =
    name: includeDirs:
    (pkgs.buildEnv {
      inherit name;
      paths = includeDirs;
      pathsToLink = [
        "/etc/dbus-1"
        "/share/dbus-1"
      ];
      ignoreCollisions = true;
    });

  dbusPaths = makeDBusPaths "dbus-paths" (
    [
      cfg.dbusPackage
      config.systemd.package
    ]
    ++ cfg.packages
  );
  initrdDBusPaths = makeDBusPaths "dbus-initrd-paths" [
    cfg.dbusPackage
    config.boot.initrd.systemd.package
  ];

  mkSystemConfContent = apparmor: servicehelper: paths: /* xml */ ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE busconfig SYSTEM "busconfig.dtd">
    <busconfig>
      <type>system</type>
      <user>messagebus</user>
      <fork/>
      <servicehelper>${servicehelper}</servicehelper>
      <pidfile>/run/dbus/pid</pidfile>
      <syslog/>
      <auth>EXTERNAL</auth>
      <listen>unix:path=/run/dbus/system_bus_socket</listen>

      <policy context="default">
        <allow user="*"/>
        <deny own="*"/>
        <deny send_type="method_call"/>
        <allow send_type="signal"/>
        <allow send_requested_reply="true" send_type="method_return"/>
        <allow send_requested_reply="true" send_type="error"/>
        <allow receive_type="method_call"/>
        <allow receive_type="method_return"/>
        <allow receive_type="error"/>
        <allow receive_type="signal"/>
        <allow send_destination="org.freedesktop.DBus" send_interface="org.freedesktop.DBus" />
        <allow send_destination="org.freedesktop.DBus" send_interface="org.freedesktop.DBus.Introspectable"/>
        <allow send_destination="org.freedesktop.DBus" send_interface="org.freedesktop.DBus.Properties"/>
        <allow send_destination="org.freedesktop.DBus" send_interface="org.freedesktop.DBus.Containers1"/>
        <deny send_destination="org.freedesktop.DBus" send_interface="org.freedesktop.DBus" send_member="UpdateActivationEnvironment"/>
        <deny send_destination="org.freedesktop.DBus" send_interface="org.freedesktop.DBus.Debug.Stats"/>
        <deny send_destination="org.freedesktop.DBus" send_interface="org.freedesktop.systemd1.Activator"/>
      </policy>

      <policy user="root">
        <allow send_destination="org.freedesktop.DBus" send_interface="org.freedesktop.systemd1.Activator"/>
      </policy>

      <policy user="root">
        <allow send_destination="org.freedesktop.DBus" send_interface="org.freedesktop.DBus.Monitoring"/>
      </policy>

      <policy user="root">
        <allow send_destination="org.freedesktop.DBus" send_interface="org.freedesktop.DBus.Debug.Stats"/>
      </policy>

      <servicedir>${paths}/share/dbus-1/system-services</servicedir>
      <includedir>${paths}/etc/dbus-1/system.d</includedir>
      <includedir>${paths}/share/dbus-1/system.d</includedir>
      <include ignore_missing="yes">/etc/dbus-1/system-local.conf</include>

      <apparmor mode="${apparmor}"/>
    </busconfig>
  '';

  mkSessionConfContent = apparmor: paths: /* xml */ ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE busconfig SYSTEM "busconfig.dtd">
    <busconfig>
      <type>session</type>
      <keep_umask/>
      <listen>unix:tmpdir=/tmp</listen>
      <auth>EXTERNAL</auth>

      <policy context="default">
        <allow send_destination="*" eavesdrop="true"/>
        <allow eavesdrop="true"/>
        <allow own="*"/>
      </policy>

      <limit name="max_incoming_bytes">1000000000</limit>
      <limit name="max_incoming_unix_fds">250000000</limit>
      <limit name="max_outgoing_bytes">1000000000</limit>
      <limit name="max_outgoing_unix_fds">250000000</limit>
      <limit name="max_message_size">1000000000</limit>
      <limit name="service_start_timeout">120000</limit>
      <limit name="auth_timeout">240000</limit>
      <limit name="pending_fd_timeout">150000</limit>
      <limit name="max_completed_connections">100000</limit>
      <limit name="max_incomplete_connections">10000</limit>
      <limit name="max_connections_per_user">100000</limit>
      <limit name="max_pending_service_starts">10000</limit>
      <limit name="max_names_per_connection">50000</limit>
      <limit name="max_match_rules_per_connection">50000</limit>
      <limit name="max_replies_per_connection">50000</limit>

      <servicedir>${paths}/share/dbus-1/services</servicedir>
      <includedir>${paths}/etc/dbus-1/session.d</includedir>
      <includedir>${paths}/share/dbus-1/session.d</includedir>
      <include ignore_missing="yes">/etc/dbus-1/session-local.conf</include>

      <apparmor mode="${apparmor}"/>
    </busconfig>
  '';

  initrdSystemConf = pkgs.writeText "initrdDBusSystem.conf" (
    mkSystemConfContent cfg.apparmor "/bin/false" initrdDBusPaths
  );
  initrdSessionConf = pkgs.writeText "initrdDBusSession.conf" (
    mkSessionConfContent cfg.apparmor initrdDBusPaths
  );
  systemConf = pkgs.writeText "dbusSystem.conf" (
    mkSystemConfContent cfg.apparmor "/run/wrappers/bin/dbus-daemon-launch-helper" dbusPaths
  );
  sessionConf = pkgs.writeText "dbusSession.conf" (mkSessionConfContent cfg.apparmor dbusPaths);
in
{
  disabledModules = [ "services/system/dbus.nix" ];

  options = {
    boot.initrd.systemd.dbus = {
      enable = mkEnableOption "dbus in stage 1" // {
        default = true;
      };
    };

    services.dbus = {

      enable = mkOption {
        type = types.bool;
        default = false;
        internal = true;
        description = ''
          Whether to start the D-Bus message bus daemon, which is
          required by many other system services and applications.
        '';
      };

      dbusPackage = lib.mkPackageOption pkgs "dbus" { };

      brokerPackage = lib.mkPackageOption pkgs "dbus-broker" { };

      implementation = mkOption {
        type = types.enum [
          "dbus"
          "broker"
        ];
        default = "broker";
        description = ''
          The implementation to use for the message bus defined by the D-Bus specification.
          Can be either the classic dbus daemon or dbus-broker, which aims to provide high
          performance and reliability, while keeping compatibility to the D-Bus
          reference implementation.
        '';
      };

      packages = mkOption {
        type = types.listOf types.path;
        default = [ ];
        description = ''
          Packages whose D-Bus configuration files should be included in
          the configuration of the D-Bus system-wide or session-wide
          message bus.  Specifically, files in the following directories
          will be included into their respective DBus configuration paths:
          {file}`«pkg»/etc/dbus-1/system.d`
          {file}`«pkg»/share/dbus-1/system.d`
          {file}`«pkg»/share/dbus-1/system-services`
          {file}`«pkg»/etc/dbus-1/session.d`
          {file}`«pkg»/share/dbus-1/session.d`
          {file}`«pkg»/share/dbus-1/services`
        '';
      };

      apparmor = mkOption {
        type = types.enum [
          "enabled"
          "disabled"
          "required"
        ];
        description = ''
          AppArmor mode for dbus.

          `enabled` enables mediation when it's
          supported in the kernel, `disabled`
          always disables AppArmor even with kernel support, and
          `required` fails when AppArmor was not found
          in the kernel.
        '';
        default = "disabled";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      system.switch.inhibitors.dbus-implementation = cfg.implementation;

      security.wrappers.dbus-daemon-launch-helper = {
        source = "${cfg.dbusPackage}/libexec/dbus-daemon-launch-helper";
        owner = "root";
        group = "messagebus";
        setuid = true;
        setgid = false;
        permissions = "u+rx,g+rx,o-rx";
      };

      users.users.messagebus = {
        uid = config.ids.uids.messagebus;
        description = "D-Bus system message bus daemon user";
        home = "/run/dbus";
        homeMode = "0755";
        group = "messagebus";
      };

      users.groups.messagebus.gid = config.ids.gids.messagebus;

      # Install dbus for dbus tools even when using dbus-broker
      environment = {
        etc = {
          "dbus-1/system.conf".source = systemConf;
          "dbus-1/session.conf".source = sessionConf;
        };
        systemPackages = [
          cfg.dbusPackage
        ];
      };

      systemd = {
        sockets.dbus = {
          description = "D-Bus System Message Bus Socket";
          listenStreams = [ "/run/dbus/system_bus_socket" ];
        };
        user.sockets.dbus = {
          description = "D-Bus User Message Bus Socket";
          listenStreams = [ "%t/bus" ];
          socketConfig.ExecStartPost = "-${config.systemd.package}/bin/systemctl --user set-environment DBUS_SESSION_BUS_ADDRESS=unix:path=%t/bus";
          wantedBy = [
            "sockets.target"
          ];
        };
      };
    }

    (mkIf config.boot.initrd.systemd.dbus.enable {
      boot.initrd.systemd = {
        users.messagebus = { };
        groups.messagebus = { };
        contents = {
          "/etc/dbus-1/system.conf".source = initrdSystemConf;
          "/etc/dbus-1/session.conf".source = initrdSessionConf;
        };
        storePaths = [
          "${config.boot.initrd.systemd.package}/share/dbus-1/system-services"
          "${config.boot.initrd.systemd.package}/share/dbus-1/system.d"
          "${initrdDBusPaths}/share/dbus-1"
        ];

        sockets.dbus = {
          description = "D-Bus System Message Bus Socket";
          listenStreams = [ "/run/dbus/system_bus_socket" ];
          unitConfig.DefaultDependencies = false;
          wantedBy = [
            "sockets.target"
          ];
        };

      };
    })

    (mkIf (config.boot.initrd.systemd.dbus.enable && (cfg.implementation == "dbus")) {
      boot.initrd.systemd = {
        storePaths = [ "${cfg.dbusPackage}/bin/dbus-daemon" ];

        services.dbus-daemon = {
          description = "D-Bus System Message Bus";
          documentation = [ "man:dbus-daemon(1)" ];
          requires = [ "dbus.socket" ];
          wantedBy = [ "multi-user.target" ];
          unitConfig.DefaultDependencies = false;
          serviceConfig = {
            Type = "notify";
            NotifyAccess = "main";
            ExecStart = "${cfg.dbusPackage}/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only";
            ExecReload = "${cfg.dbusPackage}/bin/dbus-send --print-reply --system --type=method_call --dest=org.freedesktop.DBus / org.freedesktop.DBus.ReloadConfig";
            OOMScoreAdjust = -900;
            User = "messagebus";
            Group = "messagebus";
            AmbientCapabilities = "CAP_AUDIT_WRITE";
          };
          aliases = [
            "dbus.service"
          ];
        };
      };
    })
    (mkIf (config.boot.initrd.systemd.dbus.enable && (cfg.implementation == "broker")) {
      boot.initrd.systemd = {
        storePaths = [ "${cfg.brokerPackage}/bin/dbus-broker-launch" ];

        services.dbus-broker = {
          description = "D-Bus System Message Bus";
          documentation = [ "man:dbus-broker-launch(1)" ];
          unitConfig.DefaultDependencies = false;
          after = [ "dbus.socket" ];
          before = [
            "basic.target"
            "shutdown.target"
          ];
          requires = [ "dbus.socket" ];
          conflicts = [ "shutdown.target" ];
          serviceConfig = {
            Type = "notify-reload";
            Sockets = "dbus.socket";
            OOMScoreAdjust = -900;
            LimitNOFILE = 16384;
            ProtectSystem = "full";
            PrivateTmp = true;
            PrivateDevices = true;
            ExecStart = "${cfg.brokerPackage}/bin/dbus-broker-launch --scope system --audit";
          };
          aliases = [
            "dbus.service"
          ];
        };
      };
    })

    (mkIf (cfg.implementation == "dbus") {
      systemd = {
        services.dbus-daemon = {
          description = "D-Bus System Message Bus";
          documentation = [ "man:dbus-daemon(1)" ];
          requires = [ "dbus.socket" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "notify";
            NotifyAccess = "main";
            ExecStart = "${cfg.dbusPackage}/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only";
            ExecReload = "${cfg.dbusPackage}/bin/dbus-send --print-reply --system --type=method_call --dest=org.freedesktop.DBus / org.freedesktop.DBus.ReloadConfig";
            OOMScoreAdjust = -900;
            User = "messagebus";
            Group = "messagebus";
            AmbientCapabilities = "CAP_AUDIT_WRITE";
          };
          aliases = [
            "dbus.service"
          ];
          reloadIfChanged = true;
          restartTriggers = [
            systemConf
            sessionConf
          ];
          environment = {
            LD_LIBRARY_PATH = config.system.nssModules.path;
          };
        };

        user.services.dbus = {
          description = "D-Bus User Message Bus";
          documentation = [ "man:dbus-daemon(1)" ];
          requires = [ "dbus.socket" ];
          serviceConfig = {
            Type = "notify";
            NotifyAccess = "main";
            ExecStart = "${cfg.dbusPackage}/bin/dbus-daemon --session --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only";
            ExecReload = "${cfg.dbusPackage}/bin/dbus-send --print-reply --session --type=method_call --dest=org.freedesktop.DBus / org.freedesktop.DBus.ReloadConfig";
            Slice = "session.slice";
          };
          aliases = [
            "dbus.service"
          ];
          reloadIfChanged = true;
          restartTriggers = [
            systemConf
            sessionConf
          ];
        };
      };

    })

    (mkIf (cfg.implementation == "broker") {
      environment.systemPackages = [
        cfg.brokerPackage
      ];

      systemd = {
        services.dbus-broker = {
          description = "D-Bus System Message Bus";
          documentation = [ "man:dbus-broker-launch(1)" ];
          unitConfig = {
            RequiresMountsFor = [ "/tmp" ];
            DefaultDependencies = false;
          };
          after = [ "dbus.socket" ];
          before = [
            "basic.target"
            "shutdown.target"
          ];
          requires = [ "dbus.socket" ];
          conflicts = [ "shutdown.target" ];
          serviceConfig = {
            Type = "notify-reload";
            Sockets = "dbus.socket";
            OOMScoreAdjust = -900;
            LimitNOFILE = 16384;
            ProtectSystem = "full";
            PrivateTmp = true;
            PrivateDevices = true;
            ExecStart = "${cfg.brokerPackage}/bin/dbus-broker-launch --scope system --audit";
          };
          aliases = [
            "dbus.service"
          ];
          # Don't restart dbus. Bad things tend to happen if we do.
          reloadIfChanged = true;
          restartTriggers = [
            systemConf
            sessionConf
          ];
          environment = {
            LD_LIBRARY_PATH = config.system.nssModules.path;
          };
        };

        user.services.dbus-broker = {
          description = "D-Bus User Message Bus";
          documentation = [ "man:dbus-broker-launch(1)" ];
          unitConfig.DefaultDependencies = false;
          after = [ "dbus.socket" ];
          before = [
            "basic.target"
            "shutdown.target"
          ];
          requires = [ "dbus.socket" ];
          conflicts = [ "shutdown.target" ];
          serviceConfig = {
            Type = "notify-reload";
            Sockets = "dbus.socket";
            ExecStart = "${cfg.brokerPackage}/bin/dbus-broker-launch --scope user";
            Slice = "session.slice";
          };
          aliases = [
            "dbus.service"
          ];
          # Don't restart dbus. Bad things tend to happen if we do.
          reloadIfChanged = true;
          restartTriggers = [
            systemConf
            sessionConf
          ];
        };
      };
    })

  ]);
}
