{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.machine.enableBase {
    documentation = {
      man.man-db.enable = false;
      man.mandoc.enable = true;
      doc.enable = false;
      info.enable = false;
    };
  };
}
