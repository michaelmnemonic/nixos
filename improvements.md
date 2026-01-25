# NixOS Configuration Improvements

Here is a list of potential improvements and best practice alignments for your NixOS configuration.

- [ ] **Remove duplicate package in devShell**
  - **File**: `nixos/flake.nix`
  - **Explanation**: The `cachix` package is listed twice in the `buildInputs` of the `devShell`.

- [ ] **Manage User Passwords with Agenix**
  - **File**: `nixos/users/maik.nix`
  - **Explanation**: The user password hash is currently hardcoded in the public repository. Since `agenix` is already available in your flake inputs, consider moving the password hash to an encrypted secret file (e.g., via `users.users.maik.passwordFile`) to improve security and privacy.

- [ ] **Externalize Inline Configuration Files**
  - **File**: `nixos/hosts/pluto.nix`
  - **Explanation**: Large inline configuration strings for PipeWire (EQ settings) and Fan2Go clutter the Nix module. Move these to separate files (e.g., in a `config/` directory) and use `builtins.readFile` or path literals (e.g., `text = builtins.readFile ./config/fan2go.yaml;`) to improve readability and maintainability.

- [ ] **Fix `autoUpgrade` Flake URI in Shared Config**
  - **File**: `nixos/hosts/_shared.nix`
  - **Explanation**: The `system.autoUpgrade.flake` is hardcoded to `github:michaelmnemonic/nixos/niri-on-charon`. This sets all hosts (including `pluto`, `juno`, etc.) to update from the `niri-on-charon` branch. This should likely be generic (e.g., `github:michaelmnemonic/nixos`) or overridden per-host to prevent unintended divergences.

- [ ] **Avoid Re-importing Nixpkgs in Checks**
  - **File**: `nixos/flake.nix`
  - **Explanation**: The `checks` output explicitly imports `nixpkgs` inside the `forAllSystems` loop. This causes extra evaluation overhead. Consider using `nixpkgs.legacyPackages.${system}` and applying configuration via overlays or simpler overrides to ensure consistency with the rest of the flake and speed up evaluation.

- [ ] **Deduplicate Test Configuration**
  - **File**: `nixos/tests/*.nix`
  - **Explanation**: The tests contain repeated logic to make the configuration VM-compatible (e.g., overriding filesystems, disabling LUKS, disabling specific services). Extract this common logic into a shared test module (e.g., `nixos/tests/common-vm.nix`) and import it in each test file to follow DRY (Don't Repeat Yourself) principles.

- [ ] **Use Declarative Reverse Path Filtering**
  - **File**: `nixos/hosts/pluto.nix`
  - **Explanation**: Manual `ip46tables` commands are used in `extraCommands` to handle RP filter issues for WireGuard. NixOS provides `networking.firewall.checkReversePath`. Setting this to `"loose"` is the standard declarative way to support asymmetric routing scenarios like WireGuard without raw iptables commands.

- [ ] **Fix `legacyPackages` Access in `devShell`**
  - **File**: `nixos/flake.nix`
  - **Explanation**: The `devShell` definition uses `pkgs = nixpkgs.legacyPackages.${system}.pkgs;`. Standard `legacyPackages` does not have a `pkgs` attribute; it *is* the package set. Change to `pkgs = nixpkgs.legacyPackages.${system};` to avoid errors.

- [ ] **Avoid Hardcoded IP Addresses in Shared Config**
  - **File**: `nixos/hosts/_shared.nix`
  - **Explanation**: `networking.extraHosts` hardcodes `192.168.178.30 orpheus`. This makes the config brittle and network-dependent. Prefer mDNS (Avahi) or host-specific configurations.

- [ ] **Pin `nixpkgs` Registry to Flake Inputs**
  - **File**: `nixos/hosts/_shared.nix`
  - **Explanation**: To ensure `nix shell nixpkgs#pkg` matches your system packages, link `nix.registry.nixpkgs.flake` to the flake input.

- [ ] **Define Repeated Constants**
  - **File**: `nixos/hosts/pluto.nix`
  - **Explanation**: Ports like `22000` and ranges `1714-1764` are repeated in `networking.firewall`. Use `let` bindings to define them once and reference them to ensure consistency.

- [ ] **Fix Typo in Configuration Filename**
  - **File**: `nixos/hosts/pluto.nix`
  - **Explanation**: The tmpfile configuration for Syncthing is named `var-lib-synthing.conf` (missing 'c'). Rename it to `var-lib-syncthing.conf` to avoid confusion.

- [ ] **Use `fileSystems` instead of `systemd.mounts`**
  - **File**: `nixos/hosts/pluto.nix`
  - **Explanation**: The user home directory `/home/maik` is mounted via a raw `systemd.mounts` definition. It is more idiomatic and safer to use `fileSystems."/home/maik"` with `fsType = "btrfs"` and `options`. NixOS handles the dependency ordering and mount unit generation automatically.

- [ ] **Avoid Variable Shadowing**
  - **File**: `nixos/hosts/pluto.nix`
  - **Explanation**: In the `heroic` override, the argument `pkgs` shadows the top-level `pkgs` argument. Rename the argument (e.g., to `p`) to avoid ambiguity.

- [ ] **Verify Nixpkgs Input Version**
  - **File**: `nixos/flake.nix`
  - **Explanation**: The `nixpkgs` input is pinned to `ref=nixos-25.11`, which seems to be a future version (relative to `system.stateVersion = "24.05"`). Verify if this is a typo for `nixos-24.11` or `nixos-unstable`.