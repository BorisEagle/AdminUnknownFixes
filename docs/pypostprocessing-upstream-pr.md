# Proposed PyPostProcessing upstream change (single PR)

Use this as a checklist when opening **one** pull request against [pyanodon/pypostprocessing](https://github.com/pyanodon/pypostprocessing). Review [open PRs](https://github.com/pyanodon/pypostprocessing/pulls) first to avoid duplication.

## 1. Angel’s + Py: allow AdminUnknownFixes instead of PyCoalTBaA

**File:** `prototypes/functions/compatibility.lua`

**Current (approx.):**

```lua
if mods["angelsrefining"] and not mods["PyCoalTBaA"] then
 error("\n\n\n\n\nPlease install PyCoal Touched By an Angel\n\n\n\n\n")
end
```

**Proposed:**

```lua
if mods["angelsrefining"] and not mods["PyCoalTBaA"] and not mods["AdminUnknownFixes"] then
 error("\n\n\n\n\nPlease install PyCoal Touched By an Angel\n\n\n\n\n")
end
```

**Rationale:** Legacy [PyCoalTBaA](https://mods.factorio.com/mod/PyCoalTBaA) is 1.1-era; the Angel’s + Py bridge content for Factorio 2.0 lives in [AdminUnknownFixes](https://github.com/jakegodding/AdminUnknownFixes). Players with AdminUnknownFixes should not need an empty `PyCoalTBaA` stub.

**Safety:** If the real `PyCoalTBaA` mod is enabled, `mods["PyCoalTBaA"]` is true and the error path is unchanged.

## 2. pyppatba: engine dependency (not Lua)

If the **published** `pypostprocessing` `info.json` on [mods.factorio.com](https://mods.factorio.com/mod/pypostprocessing) still lists a **required** dependency on `pyppatba` (deprecated PyPPTBaA), remove that line, or change it to **`?pyppatba`** if maintainers want optional legacy support.

Factorio does not support “`pyppatba` OR `AdminUnknownFixes`” in one dependency rule; removing the obsolete hard dependency is the correct fix once merged content ships in AdminUnknownFixes.

**Note:** At various times `main` on GitHub may already omit `pyppatba`; align the **portal** release with whatever Pyanodon wants supported.

## 3. Changelog

Add an entry to PyPP `changelog.txt` per project style (two bullets: compatibility gate; dependency cleanup if applicable).

## Suggested PR title

`Allow AdminUnknownFixes for Angel’s + Py; drop required pyppatba if present`

## Suggested PR description (template)

- **Context:** AdminUnknownFixes merges former PyCoalTBaA / PyPPTBaA (`pyppatba`) bridge work for Factorio 2.0 + Angel’s + Py.
- **Change A:** Skip the “install PyCoal Touched By an Angel” `error()` when `mods["AdminUnknownFixes"]` is set.
- **Change B:** Remove or optionalize `pyppatba` in `info.json` if it still blocks installs without the empty stub mod.
- **Links:** [AdminUnknownFixes repository](https://github.com/jakegodding/AdminUnknownFixes)
