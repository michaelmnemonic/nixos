# Plan: Optimizing NixOS Test Runs

## Objective
Reduce unnecessary test executions in GitHub Actions by verifying if a specific NixOS configuration (and its corresponding test) has already been successfully tested in a previous run.

## Research Topics

### 1. Identifying the Configuration
We need a unique identifier for the exact state of the test to be run.
*   **Derivation Hash**: In Nix, the derivation path (or output path) is a unique hash of all inputs (source code, dependencies, configuration options).
*   **Command**: `nix eval --raw .#checks.<system>.<host>.outPath` or `.drvPath`.
    *   If the `.drvPath` is the same, the build/test instructions are identical.
    *   If we use `.outPath`, it refers to the result.
    *   Since we are running `nix build .#checks...`, the derivation path of that check is the most accurate identifier.

### 2. Persistence Mechanisms in GitHub Actions
How do we store and retrieve the "verified" status across workflow runs?

#### Option A: GitHub Actions Cache
Use the `actions/cache` to store a marker file keyed by the derivation hash.
*   **Mechanism**:
    *   Generate Hash: `HASH = $(nix eval ...)`
    *   Restore Cache: Key `nixos-test-verified-${{ matrix.host }}-${{ HASH }}`.
    *   Check: If cache hit, set output `skipped=true`.
    *   Post-Run: If test passes, save cache with that key.
*   **Pros**: Built-in, easy to implement, automatic eviction (fallback to running test if evicted).
*   **Cons**: Cache eviction might cause redundant runs (acceptable).

#### Option B: Git Tags
Push a git tag upon successful test completion.
*   **Mechanism**:
    *   Generate Hash.
    *   Check Tags: `git ls-remote --tags origin refs/tags/verified-${{ matrix.host }}-${{ HASH }}`.
    *   Post-Run: `git tag ... && git push ...`
*   **Pros**: Permanent.
*   **Cons**: Clutters git tags, requires write token permissions in the workflow, potential race conditions or auth issues from forks.

#### Option C: Search Past Workflow Runs
Use `actions/github-script` to query the GitHub API for successful runs of the same commit.
*   **Cons**: `flake.lock` or other inputs might change even if the commit SHA is the same (though usually `flake.lock` is committed). The Nix derivation hash is more reliable than the Git commit SHA if we care about the *result*.

#### Option D: Cachix / Native Nix Substitution
Leverage Nix's native behavior where it checks configured binary caches (like Cachix) for the output path of the test derivation.
*   **Mechanism**:
    *   NixOS tests are derivations. When `nix build` is invoked, Nix calculates the output path.
    *   If that output path exists in Cachix (because a previous run pushed it), Nix downloads the result (usually a small report/empty file) and considers the build complete.
    *   The test logic (VM execution) is the "build" process. If substituted, the VM doesn't run.
*   **Pros**: Native Nix behavior, no extra "caching logic" in CI yaml, ensures tests run if dependencies change.
*   **Cons**: Requires the test output to have been pushed to Cachix in a previous run. If the cache isn't populated or the user doesn't have write access (e.g., PRs from forks often can't push to the maintainer's Cachix), it will rerun.

### 3. Implementation Strategy
We will proceed with **Option A (Cache)** as it is the cleanest "Cloud Native" approach for CI systems and doesn't pollute the git history.

## Steps to Execute

1.  **Research**: Verify the command to get the derivation hash for the check without building it.
2.  **Prototype**: Modify `.github/workflows/build.yml`.
    *   Add step: Calculate Hash.
    *   Add step: Check Cache.
    *   Wrap "Build" and "Run test" steps in `if: steps.cache.outputs.cache-hit != 'true'`.
    *   Add step: Save Cache (if test ran and succeeded). *Note: `actions/cache` save happens automatically at the end if configured correctly, but usually strictly for `restore` keys. We might need `actions/cache/save` or just a standard cache action that saves on success.*
    *   *Correction*: Standard `actions/cache` restores at the start and saves at the end. If we find a hit, we don't need to save. If we miss, we run the test, and then the action saves at the end. We just need to ensure we create the file to be cached.

## Detailed Workflow Logic

```yaml
- name: Calculate Derivation Hash
  id: calc-hash
  run: |
    # Calculate the drv path or out path of the test
    HASH=$(nix eval --raw .#checks.${{ matrix.system }}.${{ matrix.host }}.outPath)
    echo "hash=$HASH" >> $GITHUB_OUTPUT

- name: Check for Previous Test Success
  id: check-cache
  uses: actions/cache@v4
  with:
    path: verified-marker
    key: test-verified-${{ matrix.host }}-${{ steps.calc-hash.outputs.hash }}

- name: Build NixOS configuration
  if: steps.check-cache.outputs.cache-hit != 'true'
  run: ...

- name: Run test
  if: steps.check-cache.outputs.cache-hit != 'true'
  run: ...

- name: Create Verified Marker
  if: steps.check-cache.outputs.cache-hit != 'true'
  run: touch verified-marker
```
