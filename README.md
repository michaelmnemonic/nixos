# NixOS Configuration

This repository contains a modular NixOS configuration for managing multiple host systems using Nix flakes. The configuration is designed to be maintainable, reusable, and organized around a clear separation of concerns.

## Host Systems

The configuration currently manages three host systems:

- **pluto** (x86_64-linux) - Desktop system
- **juno** (x86_64-linux) - Tablet system
- **charon** (aarch64-linux) - Lenovo ThinkPad X13s
- **styx** (x86_64-linux) - Notebook system
- **flore** (x86_64-linux) - Notebook system

## Architecture

The configuration follows a modular approach:

1. **Shared Configuration**: Common settings applied to all hosts are defined in `hosts/_shared.nix`
2. **Host-Specific**: Each host imports the shared configuration and adds its own customizations
3. **Hardware Abstraction**: Hardware-specific settings are separated into dedicated files
4. **Capability Modules**: Features like audio, printing, and development tools are modularized
5. **Desktop Environments**: GUI configurations are kept separate and can be mixed and matched

## Getting Started

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
- Git version control
- Nix language server
- Nix code formatter

## Secure Boot

Some hosts support secure boot using the [lanzaboote](https://github.com/nix-community/lanzaboote) project.

To enable it run the following commands to generate the secure boot keys once a host is booted.

```bash
$ sudo sbctl create-keys
[sudo] password for julian:
Created Owner UUID 8ec4b2c3-dc7f-4362-b9a3-0cc17e5a34cd
Creating secure boot keys...✓
Secure boot keys created!
```

Next, rebuild the configuration.

```bash
sudo nixos-rebuild switch --flake github:michaelmnemonic/nixos
```

After you rebuild your system, check sbctl verify output:

```bash
$ sudo sbctl verify
Verifying file database and EFI images in /boot...
✓ /boot/EFI/BOOT/BOOTX64.EFI is signed
✓ /boot/EFI/Linux/nixos-generation-355.efi is signed
✓ /boot/EFI/Linux/nixos-generation-356.efi is signed
✗ /boot/EFI/nixos/0n01vj3mq06pc31i2yhxndvhv4kwl2vp-linux-6.1.3-bzImage.efi is not signed
✓ /boot/EFI/systemd/systemd-bootx64.efi is signed
```

It is expected that the files starting with kernel- are not signed.

Next, enable Secure Boot so that your firmware enforces signature verification.