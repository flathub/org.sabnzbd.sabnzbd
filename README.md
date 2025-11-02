# org.sabnzbd.sabnzbd

Flatpak for [SABnzbd](https://github.com/sabnzbd/sabnzbd).

## Build from source

### Update the manifest and requirements files

1. Update the URL and the SHA256 hash for SABnzbd in the [manifest file](https://github.com/flathub/org.sabnzbd.sabnzbd/blob/master/org.sabnzbd.sabnzbd.yaml)
2. Check/update [requirements.txt](https://github.com/flathub/org.sabnzbd.sabnzbd/blob/master/requirements.txt), mostly based on the upstream SABnzbd equivalent at <https://github.com/sabnzbd/sabnzbd/blob/master/requirements.txt>, but leave out anything not directly imported unless you need to pin a version
3. Check/update all utils listed in the manifest file (7zip, par2, unrar); pay particular attention to fixed security issues
4. Bump dbus, cryptography and/or maturin versions if necessary

### Generate Python dependencies

1. Install <https://github.com/flatpak/flatpak-builder-tools/tree/master/pip>
2. `flatpak install flathub org.freedesktop.Platform//25.08 org.freedesktop.Sdk//25.08`
3. `python3 flatpak-pip-generator.py --runtime='org.freedesktop.Sdk//25.08' --requirements-file=requirements.txt --output pypi-dependencies`

### Generate Cargo dependencies

1. Install <https://github.com/flatpak/flatpak-builder-tools/tree/master/cargo>
2. `wget -O Cargo-cryptography.lock https://github.com/pyca/cryptography/raw/refs/tags/46.0.3/Cargo.lock` (adjust the tag to match the version in your updated [manifest file](https://github.com/flathub/org.sabnzbd.sabnzbd/blob/master/org.sabnzbd.sabnzbd.yaml))
3. `python3 flatpak-cargo-generator.py Cargo-cryptography.lock -o cargo-sources-cryptography.json`
4. `wget -O Cargo-maturin.lock https://github.com/PyO3/maturin/raw/refs/tags/v1.9.4/Cargo.lock` (adjust the tag to match the version in your updated [manifest file](https://github.com/flathub/org.sabnzbd.sabnzbd/blob/master/org.sabnzbd.sabnzbd.yaml))
5. `python3 flatpak-cargo-generator.py Cargo-maturin.lock -o cargo-sources-maturin.json`

### Build, install, and test

See <https://docs.flatpak.org/en/latest/first-build.html> for details.

```bash
flatpak install org.flatpak.Builder
flatpak install flathub org.freedesktop.Platform//25.08
flatpak install flathub org.freedesktop.Sdk//25.08
flatpak install flathub org.freedesktop.Sdk.Extension.rust-stable//25.08
flatpak run org.flatpak.Builder build-dir org.sabnzbd.sabnzbd.yaml --force-clean
flatpak run org.flatpak.Builder --user --install --force-clean build-dir org.sabnzbd.sabnzbd.yaml
flatpak run org.sabnzbd.sabnzbd
```
