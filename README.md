# OneStopShop

A World of Warcraft Classic addon that helps Mages and Warlocks sell portals and summons.

## Features

- **Trade Chat Advertising** - Automatically post customizable WTS messages at configurable intervals with rate limit protection
- **Buyer Detection** - Scans trade chat and whispers for WTB/LF patterns and alerts you with sound notifications
- **Party Management** - One-click invites from detected buyer queue, optional auto-kick after service
- **Service Tracking** - Track gold earned per session, today, and all-time with persistent history
- **Quick Cast Buttons** - Secure action buttons for all your portal destinations (mages) or summon spell (warlocks)
- **Class-Aware UI** - Shows relevant features based on your class

## Supported Clients

| Version | Download |
|---------|----------|
| **Classic Era** (Vanilla, Season of Discovery, Hardcore) | `-classic.zip` |
| **TBC Anniversary** | `-tbc.zip` |
| **Cataclysm Classic** | `-cata.zip` |

## Installation

### Download Release (Recommended)

1. Go to the [Releases](../../releases/latest) page
2. Download the zip for your WoW version:
   - `OneStopShop-x.x.x-classic.zip` - Classic Era, SoD, Hardcore
   - `OneStopShop-x.x.x-tbc.zip` - TBC Anniversary
   - `OneStopShop-x.x.x-cata.zip` - Cataclysm Classic
3. Extract the zip file
4. Copy the `OneStopShop` folder to your WoW AddOns directory:
   - **Windows:** `C:\Program Files (x86)\World of Warcraft\_classic_\Interface\AddOns\`
   - **macOS:** `/Applications/World of Warcraft/_classic_/Interface/AddOns/`
5. Restart WoW or type `/reload` if already in-game

### Manual Install (from source)

```bash
git clone https://github.com/justinmaks/onestopshop.git
cp -r onestopshop/OneStopShop "/path/to/WoW/_classic_/Interface/AddOns/"
```

> **Note:** The source includes all TOC files, so it works with any Classic version.

## Usage

### Slash Commands

| Command | Description |
|---------|-------------|
| `/oss` | Toggle main window |
| `/oss config` | Open settings |
| `/oss start` | Start advertising |
| `/oss stop` | Stop advertising |
| `/oss stats` | Print statistics to chat |
| `/oss clear` | Clear buyer queue |
| `/oss log` | Manually log a service |
| `/oss help` | Show all commands |

### Minimap Button

- **Left-click**: Toggle main window
- **Right-click**: Open settings
- **Drag**: Reposition around minimap

## Configuration

Access settings via `/oss config` or right-click the minimap button.

### Advertising
- **Interval**: Time between posts (minimum 15 seconds)
- **Mage Template**: Message template with `{destinations}` and `{price}` placeholders
- **Warlock Template**: Message template with `{price}` placeholder

### Prices
- Set default prices for portals and summons (in gold)
- Used in advertisement templates and service logging

### Buyer Detection
- **Enable/Disable**: Toggle detection on or off
- **Sound**: Play notification sound when buyer detected

Default detection patterns include:
- `wtb portal`, `wtb port`, `wtb summon`
- `lf portal`, `lf mage`, `lf summon`, `lf warlock`
- `looking for portal`, `need summon`, etc.

### Party Management
- **Auto-kick**: Automatically remove party members after casting a portal/summon
- **Kick Delay**: Seconds to wait before auto-kick (default: 10)
- **Whisper on Invite**: Send a message when inviting someone

## How It Works

1. **Start Advertising**: Click "Start" or use `/oss start` to begin posting to trade chat
2. **Detect Buyers**: The addon monitors chat for people looking for services
3. **Invite**: Click "Invite" next to a detected buyer's name
4. **Cast**: Use the quick-cast buttons to prepare your portal/summon spell
5. **Log**: Services are logged automatically (if auto-kick enabled) or manually via "Log Service"
6. **Track**: View your earnings in the statistics section

## ToS Compliance

This addon is designed to comply with Blizzard's Terms of Service:
- All spell casts require player confirmation (secure action buttons)
- No fully automated gameplay
- Chat posting respects rate limits
- Party invites require manual clicks

## Development

### Local Packaging

```bash
./package.sh 1.0.0
# Creates:
#   releases/OneStopShop-1.0.0.zip (universal)
#   releases/OneStopShop-1.0.0-classic.zip
#   releases/OneStopShop-1.0.0-tbc.zip
#   releases/OneStopShop-1.0.0-cata.zip
```

### Creating a Release

Releases are automated via GitHub Actions. To create a new release:

```bash
# Update CHANGELOG.md with changes
git add -A
git commit -m "chore: prepare release 1.1.0"
git tag v1.1.0
git push origin main --tags
```

The workflow will automatically:
- Update the version in all TOC files
- Create separate zips for each WoW version
- Publish a GitHub Release with download table

### TOC Files

TOC (Table of Contents) files tell WoW how to load the addon. Each WoW client version requires a specific interface number.

#### Current TOC Files

| File | Client | Interface Version |
|------|--------|-------------------|
| `OneStopShop.toc` | Multi-client (main) | 11508, 20505, 40402 |
| `OneStopShop_Vanilla.toc` | Classic Era | 11508 |
| `OneStopShop_TBC.toc` | TBC Anniversary | 20505 |
| `OneStopShop_Cata.toc` | Cataclysm Classic | 40402 |

#### Interface Version Format

The interface number encodes the game version as `ABBCC` where:
- `A` = major version
- `BB` = minor version
- `CC` = patch version

Examples:
- Classic Era 1.15.8 → `11508`
- TBC 2.5.5 → `20505`
- Cata 4.4.2 → `40402`

#### Updating Interface Versions

When Blizzard releases a new patch, update the interface numbers:

1. Find the new version number in-game: `/dump select(4, GetBuildInfo())`
2. Or check [Warcraft Wiki - TOC format](https://warcraft.wiki.gg/wiki/TOC_format)
3. Update the relevant `.toc` files
4. Update `Interface-*` lines in the main `OneStopShop.toc`

#### Adding Support for New Clients

1. Create `OneStopShop_<Flavor>.toc` with the correct interface version
2. Add `## Interface-<Flavor>: <version>` to main `OneStopShop.toc`
3. Update `package.sh` and `.github/workflows/release.yml` to build the new package

## License

MIT
