# org.sabnzbd.sabnzbd

Flatpak for [SABnzbd](https://github.com/sabnzbd/sabnzbd).

## Build from source

### Generating Python dependencies

1. Install <https://github.com/flatpak/flatpak-builder-tools/tree/master/pip>
2. Compare and adjust packages with <https://github.com/sabnzbd/sabnzbd/blob/4.3.2/requirements.txt>
3. `flatpak install flathub org.freedesktop.Platform//22.08 org.freedesktop.Sdk//22.08`
4. `flatpak-pip-generator --runtime='org.freedesktop.Sdk//22.08' --requirements-file='requirements.txt' --output pypi-dependencies`

### Generating Cargo dependencies

1. Install <https://github.com/flatpak/flatpak-builder-tools/tree/master/cargo>
2. `wget https://raw.githubusercontent.com/pyca/cryptography/42.0.8/src/rust/Cargo.lock`
3. `python3 flatpak-cargo-generator.py Cargo.lock -o cargo-sources.json`

### Install

See <https://docs.flatpak.org/en/latest/first-build.html> for details.

```bash
flatpak install org.flatpak.Builder
flatpak install flathub org.freedesktop.Platform//23.08
flatpak install flathub org.freedesktop.Sdk//23.08
flatpak install flathub org.freedesktop.Sdk.Extension.rust-stable//23.08
flatpak run org.flatpak.Builder build-dir org.sabnzbd.sabnzbd.yaml --force-clean
flatpak run org.flatpak.Builder --user --install --force-clean build-dir org.sabnzbd.sabnzbd.yaml
flatpak run org.sabnzbd.sabnzbd
```
