{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    kdePackages.akonadi
    kdePackages.akonadi-calendar
    kdePackages.akonadi-contacts
    kdePackages.akonadi-mime
    kdePackages.akonadi-search
    kdePackages.kdepim-addons
    kdePackages.kdepim-runtime
    kdePackages.kleopatra
    kdePackages.kmail
    kdePackages.kmail-account-wizard
    kdePackages.merkuro
  ];
}
