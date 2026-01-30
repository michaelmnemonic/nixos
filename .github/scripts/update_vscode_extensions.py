#!/usr/bin/env python3
import re
import json
import urllib.request
import subprocess
import os
import sys

FILE_PATH = "capabilities/vscode-package.nix"

def get_latest_version(publisher, name):
    url = "https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery"
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json;api-version=3.0-preview.1"
    }
    data = {
        "filters": [{
            "criteria": [
                {"filterType": 7, "value": f"{publisher}.{name}"}
            ]
        }],
        "flags": 103 # IncludeVersions
    }
    
    try:
        req = urllib.request.Request(url, json.dumps(data).encode('utf-8'), headers)
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            if result['results'][0]['extensions']:
                versions = result['results'][0]['extensions'][0]['versions']
                return versions[0]['version']
            else:
                print(f"Extension {publisher}.{name} not found.")
                return None
    except Exception as e:
        print(f"Error fetching version for {publisher}.{name}: {e}")
        return None

def get_sha256_sri(publisher, name, version):
    # URL format for VSIX
    url = f"https://{publisher}.gallery.vsassets.io/_apis/public/gallery/publisher/{publisher}/extension/{name}/{version}/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"
    
    try:
        print(f"  Prefetching {url}...")
        # nix-prefetch-url returns base32 hash
        result = subprocess.run(
            ["nix-prefetch-url", url, "--name", f"{publisher}-{name}-{version}.zip"],
            capture_output=True, text=True, check=True
        )
        base32_hash = result.stdout.strip()
        
        # Convert to SRI
        sri_result = subprocess.run(
            ["nix", "hash", "to-sri", "--type", "sha256", base32_hash],
            capture_output=True, text=True, check=True
        )
        return sri_result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error calculating hash: {e.stderr}")
        return None

def main():
    if not os.path.exists(FILE_PATH):
        print(f"File {FILE_PATH} not found.")
        sys.exit(1)

    with open(FILE_PATH, 'r') as f:
        content = f.read()

    # Regex to find extensions
    # Matches: name = "..."; publisher = "..."; version = "..."; sha256 = "...";
    # Allows whitespace and newlines
    pattern = re.compile(r'(name\s*=\s*"([^"]+)";\s*publisher\s*=\s*"([^"]+)";\s*version\s*=\s*"([^"]+)";\s*sha256\s*=\s*"([^"]+)";)')
    
    replacements = []
    
    for match in pattern.finditer(content):
        full_match = match.group(1)
        name = match.group(2)
        publisher = match.group(3)
        current_version = match.group(4)
        current_sha256 = match.group(5)
        
        print(f"Checking {publisher}.{name} (current: {current_version})...")
        
        latest_version = get_latest_version(publisher, name)
        
        if latest_version and latest_version != current_version:
            print(f"  Found update: {latest_version}")
            new_sha256 = get_sha256_sri(publisher, name, latest_version)
            
            if new_sha256:
                print(f"  New SHA256: {new_sha256}")
                
                # Create the replacement string
                # We replace strictly the version and sha256 within the matched block
                new_block = full_match.replace(f'version = "{current_version}"', f'version = "{latest_version}"')
                new_block = new_block.replace(f'sha256 = "{current_sha256}"', f'sha256 = "{new_sha256}"')
                
                replacements.append((full_match, new_block))
            else:
                print("  Failed to get SHA256")
        else:
            print("  Up to date.")

    if not replacements:
        print("No updates found.")
        # No exit code 1, just success with no changes
        return

    # Apply replacements
    new_content = content
    for old, new in replacements:
        new_content = new_content.replace(old, new)

    with open(FILE_PATH, 'w') as f:
        f.write(new_content)
    
    print(f"Updated {len(replacements)} extensions.")
    # Print the updated extensions for the PR body
    print("UPDATED_EXTENSIONS=" + ",".join([f"{match[1].split('=')[1].strip().strip(';').strip().strip('"').strip()}" for match in [(r[0]) for r in replacements]]))

if __name__ == "__main__":
    main()
