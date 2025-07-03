# NixOS Configuration

This repository contains a modular NixOS configuration for managing multiple host systems using Nix flakes. The configuration is designed to be maintainable, reusable, and organized around a clear separation of concerns.

## 🖥️ Host Systems

The configuration currently manages three host systems:

- **pluto** (x86_64-linux) - Desktop system
- **juno** (x86_64-linux) - Tablet system
- **charon** (aarch64-linux) - Lenovo ThinkPad X13s

## 📁 Repository Structure

```
nixos/
├── hosts/           # Host-specific configurations
│   ├── _shared.nix  # Common configuration shared across all hosts
│   ├── pluto.nix    # Configuration for pluto host
│   ├── juno.nix     # Configuration for juno host
│   └── charon.nix   # Configuration for charon host
├── hardware/        # Hardware-specific configurations
│   ├── pluto.nix    # Hardware configuration for pluto
│   ├── juno.nix     # Hardware configuration for juno
│   └── charon.nix   # Hardware configuration for charon
├── users/           # User account configurations
│   └── maik.nix     # User configuration for maik
├── gui/             # Desktop environment configurations
│   ├── gnome.nix    # GNOME desktop environment
│   ├── plasma.nix   # KDE Plasma desktop environment
│   ├── sway.nix     # Sway window manager
│   └── niri.nix     # Niri window manager
├── capabilities/    # Modular capability configurations
│   ├── chipcards.nix    # Smart card support
│   ├── fan2go.nix       # Fan control
│   ├── gnupg.nix        # GnuPG configuration
│   ├── pipewire.nix     # PipeWire audio system
│   ├── printing.nix     # Printing support
│   ├── scanning.nix     # Document scanning
│   ├── ssh.nix          # SSH configuration
│   ├── steam.nix        # Steam gaming platform
│   ├── vscode.nix       # Visual Studio Code
│   └── vscodium.nix     # VSCodium (open source VS Code)
├── patches/         # Custom patches and modifications
├── flake.nix        # Main flake configuration
└── flake.lock       # Locked dependency versions
```

## 🏗️ Architecture

The configuration follows a modular approach:

1. **Shared Configuration**: Common settings applied to all hosts are defined in `hosts/_shared.nix`
2. **Host-Specific**: Each host imports the shared configuration and adds its own customizations
3. **Hardware Abstraction**: Hardware-specific settings are separated into dedicated files
4. **Capability Modules**: Features like audio, printing, and development tools are modularized
5. **Desktop Environments**: GUI configurations are kept separate and can be mixed and matched

## 🚀 Getting Started

### Prerequisites

- NixOS installed on your system
- Nix flakes enabled in your configuration
- Git for cloning the repository

### Initial Setup

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd nixos
   ```

2. Build and switch to a configuration:
   ```bash
   # For the juno host
   sudo nixos-rebuild switch --flake .#juno
   
   # For the charon host  
   sudo nixos-rebuild switch --flake .#charon
   
   # For the pluto host
   sudo nixos-rebuild switch --flake .#pluto
   ```

### Development Environment

A development shell is provided with useful tools:

```bash
nix develop
```

This includes:
- `gitMinimal` - Git version control
- `nil` - Nix language server
- `alejandra` - Nix code formatter

## 🔧 Configuration Features

### Shared Features (All Hosts)

- **Boot Configuration**: Systemd-boot with silent boot process
- **Time Zone**: Europe/Berlin
- **Localization**: German locale and keyboard layout
- **Security**: Immutable users, sudo access for wheel group
- **Storage**: zram swap, fscrypt home directories
- **Network**: NFS automount for shared storage
- **Nix Settings**: Flakes enabled, automatic garbage collection, auto-upgrades

### Host-Specific Features

#### Juno (Tablet)
- GNOME desktop environment with GDM
- Power optimization for mobile use
- Bluetooth and WiFi support
- Custom audio equalizer for StarLabs speakers
- Syncthing for file synchronization

#### Charon (ARM Laptop)
- KDE Plasma desktop environment
- Lenovo ThinkPad X13s ARM support via nixos-x13s
- Autologin with greetd
- Kodi media center
- Custom audio equalizer for X13s speakers
- Podman containerization

### Available Capabilities

- **Audio**: PipeWire with low-latency audio
- **Printing**: CUPS with driver support
- **Scanning**: SANE document scanning
- **Development**: VS Code/VSCodium with extensions
- **Security**: GnuPG, SSH, smart card support
- **Gaming**: Steam (when enabled)
- **System**: Fan control, power management

## 🛠️ Customization

### Adding a New Host

1. Create hardware configuration: `hardware/newhost.nix`
2. Create host configuration: `hosts/newhost.nix`
3. Add to `flake.nix` nixosConfigurations
4. Import desired capabilities and GUI modules

### Adding New Capabilities

1. Create a new module in `capabilities/`
2. Follow the existing pattern of exposing configuration options
3. Import the capability in relevant host configurations

### User Management

User configurations are defined in `users/`. To add a new user:

1. Create `users/username.nix`
2. Define user account, SSH keys, and shell preferences
3. Import in relevant host configurations

## 📦 Dependencies

The configuration uses:

- **nixpkgs**: NixOS 25.05 (stable)
- **nixos-x13s**: ARM laptop support for ThinkPad X13s

## 🔄 Maintenance

### Updates

The system is configured for automatic updates via `system.autoUpgrade`, but you can manually update:

```bash
# Update flake inputs
nix flake update

# Rebuild with new inputs
sudo nixos-rebuild switch --flake .#<hostname>
```

### Garbage Collection

Automatic garbage collection is enabled, but you can manually clean up:

```bash
# Collect garbage older than 7 days
sudo nix-collect-garbage --delete-older-than 7d

# Optimize nix store
sudo nix-store --optimize
```

## 📝 Contributing

When making changes:

1. Test configurations in a VM or on non-production systems first
2. Use `alejandra` to format Nix code
3. Keep the modular structure intact
4. Document any new capabilities or significant changes

## 🔒 Security Notes

- Users are immutable (defined in configuration)
- SSH is configured with public key authentication only
- Home directories use fscrypt encryption
- Firewall is enabled with specific port allowances
- Automatic security updates are enabled

## 📞 Support

This is a personal NixOS configuration. For general NixOS help:

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Package Search](https://search.nixos.org/)
- [NixOS Discourse](https://discourse.nixos.org/)