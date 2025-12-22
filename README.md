# org.sabnzbd.sabnzbd

Flatpak for [SABnzbd](https://github.com/sabnzbd/sabnzbd).

## Build from source

### Update the manifest and requirements files

1. `flatpak install --from https://dl.flathub.org/repo/appstream/org.flathub.flatpak-external-data-checker.flatpakref`
2. Optionally include new cryptography and/or maturin versions by temporarily uncommenting the relevant x-checker-data sections in the [manifest file](https://github.com/flathub/org.sabnzbd.sabnzbd/blob/master/org.sabnzbd.sabnzbd.yaml).
3. `flatpak run org.flathub.flatpak-external-data-checker --update --edit-only org.sabnzbd.sabnzbd.yaml`
4. Check/update [requirements.txt](https://github.com/flathub/org.sabnzbd.sabnzbd/blob/master/requirements.txt), mostly based on the upstream SABnzbd equivalent at <https://github.com/sabnzbd/sabnzbd/blob/master/requirements.txt>, but leave out anything not directly imported unless you need to pin a version

### Generate Python dependencies

1. Install <https://github.com/flatpak/flatpak-builder-tools/tree/master/pip>
2. `flatpak install flathub org.freedesktop.Platform//25.08 org.freedesktop.Sdk//25.08`
3. `python3 flatpak-pip-generator.py --runtime='org.freedesktop.Sdk//25.08' --requirements-file=requirements.txt --output pypi-dependencies`
4. `python3 flatpak-pip-generator.py --runtime='org.freedesktop.Sdk//25.08' --requirements-file=requirements-flatpak.txt --output pypi-dependencies-flatpak`
5. `python3 flatpak-pip-generator.py --runtime='org.freedesktop.Sdk//25.08' --requirements-file=requirements-cryptography.txt --output pypi-dependencies-cryptography`
6. `python3 flatpak-pip-generator.py --runtime='org.freedesktop.Sdk//25.08' --requirements-file=requirements-orjson.txt --output pypi-dependencies-orjson`

### Generate Cargo dependencies

1. Install <https://github.com/flatpak/flatpak-builder-tools/tree/master/cargo>
2. `wget -O Cargo-cryptography.lock https://github.com/pyca/cryptography/raw/refs/tags/46.0.3/Cargo.lock` (adjust the tag to match the version in your updated [manifest file](https://github.com/flathub/org.sabnzbd.sabnzbd/blob/master/org.sabnzbd.sabnzbd.yaml))
3. `python3 flatpak-cargo-generator.py Cargo-cryptography.lock -o cargo-sources-cryptography.json`
4. `wget -O Cargo-maturin.lock https://github.com/PyO3/maturin/raw/refs/tags/v1.10.2/Cargo.lock` (adjust the tag to match the version in your updated [manifest file](https://github.com/flathub/org.sabnzbd.sabnzbd/blob/master/org.sabnzbd.sabnzbd.yaml))
5. `python3 flatpak-cargo-generator.py Cargo-maturin.lock -o cargo-sources-maturin.json`
6. `wget -O Cargo-orjson.lock https://raw.githubusercontent.com/ijl/orjson/refs/tags/3.11.5/Cargo.lock` (adjust the tag to match the version in your updated [manifest file](https://github.com/flathub/org.sabnzbd.sabnzbd/blob/master/org.sabnzbd.sabnzbd.yaml))
7. `python3 flatpak-cargo-generator.py Cargo-orjson.lock -o cargo-sources-orjson.json`

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
