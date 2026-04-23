# AdminUnknownFixes

Bridge mod for **Pyanodon**, **Angel’s**, and **Bob’s** on Factorio 2.0: merged compatibility content, recipe/tech fixes, and related shims.

Homepage: [https://github.com/jakegodding/AdminUnknownFixes](https://github.com/jakegodding/AdminUnknownFixes)

## Building release zips

From the repository root:

- **Windows:** `pwsh -File scripts/package-mods.ps1`
- **Unix:** `./scripts/package-mods.sh`

Outputs under `dist/` (gitignored): main mod plus two stub mods. After each run, **stub** zips are also copied to `stubs/` in the repo for direct download (see below).

## Manual stub installs

Some setups still need empty sibling mods so PyPostProcessing’s dependency or Angel’s + Py gate is satisfied. If your mod list or PyPP version still requires them, download and install **both** zips into your Factorio `mods` folder (same place as other mods). You can enable them from the in-game mod UI; they add no prototypes.

| Stub | Direct download (raw `main` branch) |
|------|-------------------------------------|
| pyppatba | [pyppatba_0.0.1.zip](https://github.com/jakegodding/AdminUnknownFixes/raw/main/stubs/pyppatba_0.0.1.zip) |
| PyCoalTBaA | [PyCoalTBaA_0.0.1.zip](https://github.com/jakegodding/AdminUnknownFixes/raw/main/stubs/PyCoalTBaA_0.0.1.zip) |

**Install:** copy each `*_0.0.1.zip` into `%APPDATA%\Factorio\mods` (Windows) or `~/.factorio/mods` (Linux/macOS). Factorio 2.0 loads mods from zip files named `Name_Version.zip` in that folder. Then restart and enable the stubs if they are not auto-enabled.

A future **PyPostProcessing** release may remove the need for these stubs when **AdminUnknownFixes** is present; see [docs/pypostprocessing-upstream-pr.md](docs/pypostprocessing-upstream-pr.md) for the proposed upstream change.
