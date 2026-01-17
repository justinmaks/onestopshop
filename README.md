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

- WoW Classic Era (1.14.x)
- TBC Classic (2.5.x)
- WotLK Classic (3.4.x)

## Installation

1. Download or clone this repository
2. Copy the `OneStopShop` folder to your WoW addons directory:
   - **Windows:** `C:\Program Files (x86)\World of Warcraft\_classic_\Interface\AddOns\`
   - **macOS:** `/Applications/World of Warcraft/_classic_/Interface/AddOns/`
3. Restart WoW or type `/reload` if already in-game
4. Enable the addon in the character select screen if needed

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

## License

MIT
