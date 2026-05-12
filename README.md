<!--MODERNIZED:v2-->
# Qatindex

> A searchable index of Quick Access Toolbar (QAT) and ribbon command identifiers for Microsoft Office.

[![Live page](https://img.shields.io/badge/live-page-ff2e93?style=for-the-badge)](https://socrtwo.github.io/qatindex-SF/)
[![Releases](https://img.shields.io/github/v/release/socrtwo/qatindex-SF?style=for-the-badge&color=7c3aed)](https://github.com/socrtwo/qatindex-SF/releases)
[![License](https://img.shields.io/github/license/socrtwo/qatindex-SF?style=for-the-badge&color=22d3ee)](https://github.com/socrtwo/qatindex-SF/blob/main/LICENSE)
[![Last commit](https://img.shields.io/github/last-commit/socrtwo/qatindex-SF?style=for-the-badge&color=34d399)](https://github.com/socrtwo/qatindex-SF/commits)
[![Data: OfficeDev](https://img.shields.io/badge/data-OfficeDev%2Foffice--fluent--ui--command--identifiers-0078d4?style=for-the-badge)](https://github.com/OfficeDev/office-fluent-ui-command-identifiers)

🌐 **Live:** https://socrtwo.github.io/qatindex-SF/
📦 **Downloads:** [Releases](https://github.com/socrtwo/qatindex-SF/releases)
📂 **Source:** [socrtwo/qatindex-SF](https://github.com/socrtwo/qatindex-SF)

---

Qatindex started as a static Excel/PowerPoint workbook listing the QAT command IDs for Office 2007/2010. It has been **modernized** into a fast, in-browser command browser that pulls live data from Microsoft's official [`OfficeDev/office-fluent-ui-command-identifiers`](https://github.com/OfficeDev/office-fluent-ui-command-identifiers) repository (Microsoft 365 — Current Channel).

## What's new

- 🚀 **Live data from Microsoft** — pulls the official `*controls.xlsx` files from `OfficeDev/office-fluent-ui-command-identifiers` at runtime; no stale snapshots to maintain.
- 🧭 **All major Office apps** — Excel, Word, PowerPoint, Outlook, Access, OneNote, Visio, Project, and Publisher.
- 🔎 **Instant search** — debounced, full-row search across Control Name, Tab, Tab Set, Group, Parent Control, and Type.
- 🎛️ **Filters & sorting** — narrow by Tab or Control Type, sort every column.
- 🔗 **Deep-linkable URLs** — your app, search query, and filters live in the URL bar (`?app=excel&q=cell&tab=Home`).
- ⌨️ **Keyboard-first** — `/` or `⌘K` to focus search, `Esc` to clear or close.
- 📋 **Copy-to-clipboard** for Control Names — paste straight into your `customUI.xml`, VBA, or PowerShell `Set-OfficeQuickAccessToolbar`.
- 🎨 **Modern responsive UI** with a sticky header, badged control types, and dark theme.
- 🔒 **No backend, no analytics, no API key** — everything runs client-side from raw GitHub.

## Try it

➡️ **https://socrtwo.github.io/qatindex-SF/**

Examples:

- [Excel · search "freeze"](https://socrtwo.github.io/qatindex-SF/?app=excel&q=freeze)
- [Word · Home tab](https://socrtwo.github.io/qatindex-SF/?app=word&tab=Home)
- [PowerPoint · galleries only](https://socrtwo.github.io/qatindex-SF/?app=powerpoint&type=gallery)
- [Outlook Explorer commands](https://socrtwo.github.io/qatindex-SF/?app=outlook)

## How it works

The web app loads Microsoft's `*controls.xlsx` files directly from `raw.githubusercontent.com`, parses them in the browser with [SheetJS](https://sheetjs.com/), and renders a virtualized, filterable table. Files are HTTP-cached, so subsequent loads are near-instant. Apps you haven't opened are pre-warmed in the background.

Columns surfaced (verbatim from Microsoft's data):

| Column | Description |
| --- | --- |
| **Control Name** | The `idMso` / `Control Name` used in QAT XML, custom Ribbon XML, VBA `CommandBars.ExecuteMso`, etc. |
| **Control Type** | `button`, `toggleButton`, `gallery`, `menu`, `comboBox`, … |
| **Tab Set** | Contextual tab set (e.g. *PivotTable Tools*) or *None (Quick Access Toolbar)*. |
| **Tab** | The ribbon tab (Home, Insert, …) or *Quick Access Toolbar*. |
| **Group / Context Menu** | The ribbon group or context-menu group the control lives in. |
| **Parent Control** | Parent gallery/menu, when nested. |
| **Policy ID** | Numeric Office policy/control ID. |

## Legacy downloads (Office 2007 / 2010)

The original Excel macro workbooks are still available for users who need the offline VBA-based index:

- `Excel-Command-Index.xlsm`
- `PowerPoint-Command-Index.xlsm`
- [`releases/excel-powerpoint-qat-index.zip`](releases/excel-powerpoint-qat-index.zip)

These cover Office 2007/2010. For Microsoft 365 / Office 2019+ commands, use the live web index above.

## Using a Control Name

Once you've copied a Control Name (e.g. `PivotTableInsertCalculatedField`):

**VBA**
```vba
Application.CommandBars.ExecuteMso "PivotTableInsertCalculatedField"
```

**Ribbon / QAT XML** (`customUI.xml`)
```xml
<button idMso="PivotTableInsertCalculatedField" />
```

**PowerShell** (read the current QAT)
```powershell
Get-Item "$env:LOCALAPPDATA\Microsoft\Office\Excel.officeUI"
```

## System requirements

- Any modern browser (Chrome, Edge, Firefox, Safari) — the web index has no other requirements.
- The legacy workbooks require Microsoft Office 2007 or later with macros enabled.

## Contributing

Issues and PRs welcome at <https://github.com/socrtwo/qatindex-SF/issues>.

If you spot a missing or stale command, please first check whether it's already in [OfficeDev's upstream repo](https://github.com/OfficeDev/office-fluent-ui-command-identifiers) — this site is a UI on top of that data.

Good areas for contribution:

- Outlook item-type spreadsheets (mail, appointment, task, …) are not yet wired into the app picker.
- Bundling the upstream XLSX files at build time as a fallback for offline use.
- Surfacing keyboard shortcuts (where Microsoft documents them).

## License

MIT — see [LICENSE](LICENSE). Microsoft's command-identifier data is also MIT-licensed by OfficeDev.

## Origin

Originally hosted on SourceForge ([qatindex](https://sourceforge.net/projects/qatindex/)), migrated to GitHub via [SF2GH Migrator](https://github.com/socrtwo/sf-to-github), and modernized here on top of Microsoft's official command-identifier dataset.

---

*Maintained by [@socrtwo](https://github.com/socrtwo)*
