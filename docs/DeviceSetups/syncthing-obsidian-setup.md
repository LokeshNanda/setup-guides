# Replace Obsidian Sync with Syncthing (iPad + Mac + Windows + Pixel)

I like Obsidian’s “local-first” philosophy, but I didn’t love the idea of adding *another* recurring subscription just to keep my notes in sync. I already had an iPad + Mac in the Apple ecosystem, and a Windows laptop + Pixel phone outside it—so I tried an experiment:

- Use **iCloud Drive** as the sync layer between **iPad Air ↔ Mac Mini**
- Use **Syncthing** as the sync layer between **Mac Mini ↔ Windows Laptop ↔ Pixel**

It’s been a solid fit for my workflow (mostly on my home network), and it effectively replaced my need for Obsidian Sync.

> **Important**
> This guide documents *my* setup: **devices must be on the same network** for sync (no relay / no “sync from anywhere” expectation). If you want anywhere-sync, you can still use Syncthing—but that’s a different configuration and threat model.

---

## What you get (and what you don’t)

### What this setup is great at

- **No recurring sync subscription**
- **Fast local sync** across all devices (LAN/Wi‑Fi)
- A vault that stays as plain files you control
- Cross-platform support: iPad + macOS + Windows + Android

### What this setup is not

- Not “always synced from anywhere” (by design, in this doc)
- Not as hands-off as a managed sync service
- Conflict handling depends on how you edit and how you configure versioning

---

## Architecture (how the pieces connect)

This setup uses the Mac Mini as a *bridge* between iCloud Drive and Syncthing:

- iPad writes to the vault in **iCloud Drive**
- Mac Mini receives it via **iCloud Drive**
- Syncthing on the Mac Mini then shares that same folder to Windows and Pixel

### ASCII architecture diagram

```text
                         (Same Wi‑Fi / LAN)

          +------------------- iCloud Drive -------------------+
          |                                                     |
      +---v---+                                           +-----v-----+
      |  iPad | <------------- iCloud sync --------------> |  Mac Mini |
      +---+---+                                           +-----+-----+
                                                           |     |
                                                           | Syncthing
                                                           |     |
                                                +----------+     +----------+
                                                |                           |
                                           +----v----+                 +----v----+
                                           | Windows |                 |  Pixel  |
                                           | Laptop  |                 |  Phone  |
                                           +---------+                 +---------+
```

---

## Devices in this guide

- **iPad Air** (Obsidian vault created here first)
- **Mac Mini** (iCloud + Syncthing “bridge” device)
- **Windows Laptop** (Syncthing + Obsidian)
- **Pixel phone** (Syncthing + Obsidian)

---

## Prerequisites

- Obsidian installed on all devices you plan to edit on
- iCloud Drive enabled on iPad and Mac Mini (same Apple ID)
- Syncthing installed on:
  - Mac Mini
  - Windows Laptop
  - Pixel phone

> **Tip**
> Keep the Mac Mini reliably online (or at least online when you want sync). In this architecture, it’s the hub.

---

## Step-by-step setup

### 1) Create the vault on iPad (first)

Creating the vault on iPad first keeps the Apple-side path simple and ensures iCloud Drive is the home directory from day one.

1. Open **Obsidian** on iPad
2. Tap **Create new vault**
3. Choose a location in **iCloud Drive** (via the Files picker)
4. Name the vault (example: `Vault` or `ObsidianVault`)

> **Important**
> Keep the vault in a single dedicated folder. Don’t store it inside a folder that has lots of unrelated content—you’ll thank yourself when sharing with Syncthing.

---

### 2) Confirm iCloud Drive sync to Mac Mini

1. On Mac Mini, ensure iCloud Drive is enabled and fully signed in
2. Wait for the vault folder to appear locally under iCloud Drive
3. Open Obsidian on Mac Mini and **open the iCloud vault**

> **Important**
> Syncthing needs local access to files. If macOS “optimizes storage” and keeps files cloud-only, you may see inconsistent syncing behavior.

---

### 3) Install and start Syncthing on Mac Mini, Windows, and Pixel

On each device:

- Install Syncthing
- Open Syncthing’s UI and note the **Device ID**
- Ensure Syncthing is allowed to run in the background (especially on mobile)

> **Tip**
> On Android, battery optimizations can quietly stop background sync. If you notice “it only syncs when I open the app,” adjust battery settings for Syncthing.

---

### 4) Add the vault folder to Syncthing on the Mac Mini

In Syncthing (Mac Mini):

1. Click **Add Folder**
2. **Folder label**: `Obsidian Vault` (or similar)
3. **Folder path**: select the vault folder inside iCloud Drive
4. Save

> **Important**
> Share the **vault root folder** (the folder that contains your notes and the `.obsidian` directory). Avoid sharing a higher-level iCloud directory.

---

### 5) Pair the Mac Mini with Windows and Pixel

You’ll connect each device to the Mac Mini.

On the Mac Mini Syncthing UI:

1. **Add Remote Device**
2. Enter the Windows device ID and give it a name
3. Repeat for the Pixel device ID

Then accept the pairing requests on Windows and Pixel.

---

### 6) Share the vault folder to Windows and Pixel

On the Mac Mini Syncthing UI:

1. Open the folder settings for your vault
2. Under **Sharing**, select:
   - Windows Laptop
   - Pixel phone
3. Save

On Windows and Pixel:

1. Accept the share
2. Choose the local folder path where the vault should live
3. Let the initial sync complete

---

### 7) Open the synced vault in Obsidian (Windows + Pixel)

Once syncing finishes:

- On **Windows**: Obsidian → **Open folder as vault**
- On **Pixel**: Obsidian → select/open the synced vault folder (based on your Android file picker flow)

> **Important**
> For the first run, wait until the initial sync is stable before editing across multiple devices. Initial indexing + plugin metadata can create a burst of file changes.

---

## Recommended configuration (production-grade stability tips)

These are the settings and habits that keep this setup reliable.

### Keep the Mac Mini as the “bridge” (always-on when possible)

- iPad only talks to the Mac via iCloud
- Windows/Pixel only talk to the iPad *through* the Mac (via iCloud + Syncthing)

If the Mac is offline, the “two sync worlds” won’t bridge.

### Enable file versioning (helps recover from mistakes)

Syncthing can keep older copies when files change or conflicts happen.

- **Recommendation**: Enable **File Versioning** on the vault folder in Syncthing.
- This helps when:
  - you overwrite something unintentionally
  - a conflict copy gets created
  - plugin metadata causes unexpected churn

**Important:** Versioning uses disk space. Set sensible retention.

### Avoid simultaneous editing of the same note

This is the easiest way to prevent conflicts:

- Finish editing on one device
- Wait for sync to settle
- Then switch devices

### Decide whether to sync `.obsidian`

The `.obsidian` folder contains settings, themes, and plugin configuration.

- **Syncing it** gives you a consistent experience everywhere
- **Not syncing it** can reduce platform-specific weirdness

> **Practical recommendation**
> Start by syncing `.obsidian` (simpler). If you hit plugin issues across platforms, revisit this decision and reduce plugin complexity.

### Keep filenames and paths cross-platform friendly

- Avoid characters that behave differently across platforms
- Keep paths short and simple
- Prefer consistent naming conventions (especially for attachments)

---

## Limitations (in this specific setup)

- **Same network expectation**: I only rely on this setup when devices are on the same Wi‑Fi/LAN.
- **No cloud relay in my configuration**: I’m not optimizing for syncing while away from home.
- **Hub dependency**: Mac Mini must be online for Apple-side changes to flow to Windows/Pixel (and vice versa).
- **Conflicts are still possible**: Any file sync system can conflict when edits happen concurrently.

---

## Pros and cons

### Pros

- **Cost**: no recurring sync subscription
- **Speed**: very fast on local network
- **Ownership**: your vault remains plain files you control
- **Flexibility**: mix Apple + Windows + Android without a single vendor lock-in

### Cons

- More moving parts than a managed service
- Requires some operational awareness (hub device, background syncing, occasional conflicts)
- Not designed here for “sync everywhere instantly”

---

## Who should use this

This setup is a good fit if:

- You mostly work on **one primary network** (home/office)
- You want **subscription-free** syncing and don’t mind some setup
- You’re comfortable with a “bridge” device (Mac Mini) acting as the hub

You may prefer Obsidian Sync (or another managed service) if:

- You need effortless syncing across networks while traveling
- You frequently edit the same note from multiple devices at once
- You want minimal troubleshooting and maximum convenience

---

## Security considerations

At a practical level, sync security is only as strong as your devices and your habits.

- **Device trust**: if one device is compromised, the vault is compromised on that device.
- **Local network**: syncing on LAN reduces exposure to internet-based threat surfaces, but doesn’t automatically make things “secure.”
- **Sensitive notes**: if you store secrets or highly sensitive information, consider an additional encryption layer or a stricter policy about what goes into your vault.

> **Important**
> Don’t confuse “open-source” with “automatically secure.” Keep OS updates current, use strong device locks, and enable disk encryption where available.

---

## Obsidian Sync vs Syncthing (quick comparison)

| Category | Obsidian Sync | Syncthing (this setup) |
|---|---|---|
| Pricing | Paid subscription | Free / open-source |
| Setup time | Low | Medium |
| Works away from home networks | Yes | **Not in this guide** |
| Sync model | Managed service | Peer-to-peer device sync |
| Reliability (hands-off) | High | Depends on your setup (hub, background sync, versioning) |
| Conflict handling | Generally smoother | Possible conflict copies (mitigated by habits + versioning) |
| Best for | “Set it and forget it” | DIY, local-network-centric, cost-sensitive workflows |

---

## Cost notes

I did this mainly for subscription hygiene:

- Obsidian Sync is convenient, but it’s still a recurring line item.
- Syncthing is free, and iCloud Drive was already part of my Apple ecosystem.

**If you’re happy with Obsidian Sync, keep it.** But if your workflow is mostly at home and you enjoy owning the plumbing, this setup can remove a subscription without sacrificing day-to-day usability.

---

## Final thoughts

This is a pragmatic compromise: I traded “sync anywhere instantly” for **fast, local, subscription-free syncing** that fits how I actually use my devices.

If you’re mostly on one network and you want Obsidian across iPad, macOS, Windows, and Android without paying for sync, this iCloud + Syncthing bridge is a clean, repeatable way to do it.
