# OneLake Explorer Setup Guide

## Contoso Banque — Churn Analysis Workshop

This guide provides detailed setup instructions and troubleshooting for **Microsoft OneLake file explorer** — a Windows application that lets you browse and interact with Microsoft Fabric OneLake data directly from Windows File Explorer.

---

## What Is OneLake Explorer?

OneLake is the unified storage layer underneath all Microsoft Fabric items (Lakehouses, Warehouses, Semantic Models, etc.). **OneLake file explorer** is a Windows application that:

- Mounts your Fabric workspaces as a folder in Windows File Explorer.
- Lets you browse files and folders in OneLake without using a browser.
- Supports downloading files locally (on-demand sync).
- Lets you upload files to the `Files/` section of a Lakehouse by simply dragging and dropping.

> **Limitation:** OneLake Explorer is read/write for `Files/`, but you **cannot** write Delta tables from your local machine. Always use Fabric notebooks to write or modify `Tables/`.

---

## System Requirements

| Requirement | Details |
|---|---|
| Operating System | Windows 10 (version 1903 or later) or Windows 11 |
| Architecture | x64 or ARM64 |
| Microsoft Fabric access | You need a workspace with capacity assigned |
| Account | Work or school account (same as your Fabric tenant) |

---

## Installation

### Option A — Microsoft Store (Recommended)

1. Open the **Microsoft Store** on your Windows machine.
2. Search for **"OneLake"** or **"Microsoft OneLake"**.
3. Click **Install**.
4. After installation, the app icon appears in your system tray (bottom-right corner of the taskbar).

### Option B — Direct Download

1. Open the [OneLake file explorer documentation page](https://learn.microsoft.com/fr-fr/fabric/onelake/onelake-file-explorer).
2. Click the download link for the latest version.
3. Run the installer and follow the prompts.

---

## First-Time Sign-In

1. After installation, click the **OneLake icon** in the Windows system tray (it may be hidden — click the `^` arrow to expand the tray).
2. Click **Sign in**.
3. A browser window opens. Sign in with your **organizational (work or school) account** — the same account you use to access [https://app.fabric.microsoft.com](https://app.fabric.microsoft.com).
4. After signing in, click **Accept** if prompted to grant permissions.
5. Return to the system tray — the OneLake icon should now show a green check mark or no error indicator.

> **Critical:** You must use the exact same account for OneLake Explorer and Fabric. Using a personal Microsoft account or a different work account will result in your workspaces not appearing.

---

## Browsing Your Data

### Accessing OneLake in File Explorer

1. Press `Windows + E` to open Windows File Explorer.
2. In the left navigation pane, look for **"OneLake - Microsoft"** (or a variant showing your organization name).
3. If you don't see it immediately, scroll down in the left pane or check **"This PC"** → look for a new drive letter or folder.
4. Open the folder to see your Fabric workspaces.

### Navigating to Your Lakehouse

The folder structure mirrors Fabric exactly:

```
OneLake - Microsoft
└── ChurnAnalysis-Workshop/             ← Your Fabric workspace
    └── ChurnAnalysisLH.Lakehouse/      ← Your Lakehouse item
        ├── Files/                      ← File storage (raw data)
        │   └── churn/
        │       └── raw/
        │           ├── customers/
        │           ├── accounts/
        │           └── ...
        └── Tables/                     ← Delta tables (read-only from Explorer)
            ├── customers/
            ├── accounts/
            └── ...
```

---

## Downloading Files (On-Demand Sync)

OneLake Explorer uses **cloud-only (placeholder) files** by default. A file may appear in Explorer but has not been downloaded to your local disk yet. You can identify cloud-only files by:
- A cloud icon overlay on the file/folder.
- Very small file size (a few KB for a large file).

### To download a file locally:
- **Double-click** the file to open it — it will download automatically.
- Or right-click → **"Always keep on this device"** — this keeps it downloaded permanently.

### To free up local disk space:
- Right-click → **"Free up space"** — the file stays in OneLake but is removed from your local disk.

---

## Syncing New Content from Fabric

After running Fabric notebooks that write new files or tables, OneLake Explorer may not immediately show the new content. To refresh:

1. In Windows File Explorer, navigate to the workspace or Lakehouse folder.
2. Right-click on the folder.
3. Select **"Sync from OneLake"**.

OneLake Explorer will check for changes and update the local view. This usually takes 10–60 seconds.

> **Note:** For large datasets (like the transaction table), the sync may take a few minutes. Be patient after running notebook 01.

---

## Uploading Files to Files/

To upload a local file to a Lakehouse's `Files/` section:

1. In Windows File Explorer, navigate to the desired folder within `Files/`.
2. Drag and drop your file into that folder.
3. Wait for the sync icon to stop spinning.
4. Verify in the Fabric portal that the file has been uploaded.

> **Warning:** Do not drag files into the `Tables/` folder. Delta tables have a specific internal structure and must be written by Spark.

---

## Troubleshooting

### Workspace Not Visible

| Possible Cause | Solution |
|---|---|
| Signed in with wrong account | System tray → right-click OneLake icon → Sign out → Sign in with the correct account |
| Feature disabled by admin | Ask your tenant admin to enable "OneLake file explorer" in the Fabric Admin Portal under Tenant Settings |
| Workspace has no capacity | Ensure your workspace has a Fabric trial or capacity assigned |
| Fresh sign-in — sync not yet complete | Wait 1–2 minutes after signing in, then reopen File Explorer |

### Files Not Appearing After Notebook Run

1. Right-click the Lakehouse folder → **"Sync from OneLake"**.
2. Wait 1–2 minutes.
3. If still not appearing, close and reopen Windows File Explorer.
4. If the issue persists, sign out and sign back in to OneLake Explorer.

### Sync Errors (Red X on Icon)

- Check your internet connection.
- Look at the sync status in the system tray by hovering over the OneLake icon.
- Common causes: network timeout, file path too long (Windows 260-character limit), reserved characters in file names.

### Windows Reserved Characters

OneLake file names cannot contain: `\ / : * ? " < > |`
Fabric automatically creates safe names, but if you manually create files, avoid these characters.

### Long File Paths

Windows has a 260-character path limit by default. If you encounter errors with deeply nested paths, enable long file path support:
1. Open Group Policy Editor (`gpedit.msc`).
2. Navigate to: Computer Configuration → Administrative Templates → System → Filesystem.
3. Enable **"Enable Win32 long paths"**.

### OneLake Explorer Not Starting

1. Try restarting the application: right-click the system tray icon → **Quit**, then relaunch from the Start Menu.
2. If the icon is missing, launch from: Start Menu → "OneLake file explorer".
3. As a last resort, uninstall and reinstall from the Microsoft Store.

---

## Post-Workshop Validation Checklist

After completing the workshop, confirm you can:

- [ ] See `ChurnAnalysis-Workshop` in the OneLake folder.
- [ ] See `ChurnAnalysisLH.Lakehouse` inside the workspace.
- [ ] Navigate to `Files/churn/raw/customers/` and see Parquet files.
- [ ] Navigate to `Tables/customer_360/` and see Delta files (`_delta_log/`, `.parquet` files).
- [ ] Right-click and sync without errors.

---

## Additional Resources

- [OneLake file explorer official documentation (FR)](https://learn.microsoft.com/fr-fr/fabric/onelake/onelake-file-explorer)
- [OneLake overview](https://learn.microsoft.com/fabric/onelake/onelake-overview)
- [Fabric Lakehouse overview](https://learn.microsoft.com/fabric/data-engineering/lakehouse-overview)
