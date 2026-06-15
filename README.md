# org.sabnzbd.sabnzbd

Flatpak for [SABnzbd](https://github.com/sabnzbd/sabnzbd).

## Build from source

The information and commands below describe a completely manual update and build of the flatpak. In practice most of the work is automated via flathub's external-data-checker, this repository's auto-update workflow, and flathub-infra's build and publish actions triggered by commits to the master branch. Unless bugs show up or the automation goes off the rails, only the manifest (org.sabnzbd.sabnzbd.yaml) and the requirements.txt file occasionally need manual edits; python3-requirements.yaml file is fully generated.

### Update the manifest and requirements files

1. `flatpak install --from https://dl.flathub.org/repo/appstream/org.flathub.flatpak-external-data-checker.flatpakref`
2. `flatpak run org.flathub.flatpak-external-data-checker --update --edit-only org.sabnzbd.sabnzbd.yaml`
3. Check/update [requirements.txt](https://github.com/flathub/org.sabnzbd.sabnzbd/blob/master/requirements.txt), mostly based on the upstream SABnzbd equivalent at <https://github.com/sabnzbd/sabnzbd/blob/master/requirements.txt>, but leave out anything not directly imported unless you need to pin a version

### Generate Python dependencies

1. Install <https://github.com/flatpak/flatpak-builder-tools/tree/master/pip>
2. `flatpak install flathub org.freedesktop.Platform//25.08 org.freedesktop.Sdk//25.08`
3. `python3 flatpak-pip-generator.py --runtime=org.freedesktop.Sdk//25.08 --yaml --checker-data --requirements-file=requirements.txt --prefer-wheels=cryptography,orjson`

### Build, install, and test

See <https://docs.flatpak.org/en/latest/first-build.html> for details.

```bash
flatpak install org.flatpak.Builder
flatpak install flathub org.freedesktop.Platform//25.08
flatpak install flathub org.freedesktop.Sdk//25.08
flatpak run org.flatpak.Builder build-dir org.sabnzbd.sabnzbd.yaml --force-clean
flatpak run org.flatpak.Builder --user --install --force-clean build-dir org.sabnzbd.sabnzbd.yaml
flatpak run org.sabnzbd.sabnzbd
```
