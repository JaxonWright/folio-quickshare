# folio-quickshare

A [Folio](https://github.com/omacom/folio) plugin that sends files to nearby Android devices with Quick Share. Select files, right-click, and choose a device under **Share › Quick Share**.

The plugin does no networking itself. It calls the [quickshare](https://github.com/JaxonWright/quickshare) command, the same way Folio's Taildrop entry calls `tailscale`.

## Requirements

- Folio 0.4.0 or newer.
- Linux on x86_64 or aarch64. On other architectures, build [quickshare](https://github.com/JaxonWright/quickshare) 0.2.0 or newer and put it on `PATH`.
- `jq` and `curl`, which Omarchy already has.

## Install

```sh
git clone https://github.com/JaxonWright/folio-quickshare ~/.local/share/folio/plugins/quickshare
```

Press F5 in an open Folio window, or start Folio. That is the whole install. On its first poll the plugin downloads the [quickshare](https://github.com/JaxonWright/quickshare/releases) release it pins, about 6 MB, into its own `bin/` folder, and checks it against a SHA-256 written in `lib.sh`. A slow download carries on over the next polls. Phones start showing up once it finishes.

To update, run `git pull` in that folder. An update also moves the pinned quickshare version, so the two always match.

## How it behaves

Every 10 seconds Folio runs `devices`, which runs `quickshare browse --no-wake` for 2 seconds and lists each device it hears. `--no-wake` matters here. Folio polls in the background whether or not a menu is open, and a plain `browse` sends the Bluetooth advertisement that wakes Quick Share on every phone in range. So a phone shows up under **Quick Share** only while it is already visible, which usually means its Quick Share screen is open or its visibility is set to Everyone. The submenu is hidden while no device is visible.

Choosing a device runs `send`, which runs `quickshare send` and waits for the phone's owner to tap Accept. The send wakes that phone. While it waits and copies, Folio shows "Sending to" and the device's name, then "Sent to" and the name, or why it did not go: the owner declined, cancelled, or quickshare's own error. Closing Folio ends a send that is still running.

The entry is hidden while a folder is selected, because Quick Share sends files.

Sending needs no firewall rule, because this computer opens every connection.

## Tests

```sh
tests/run
```

The tests run `devices` and `send` against a stand-in `quickshare` and check the JSON Folio would read.

## License

GPL-3.0-only, to match quickshare. See `LICENSE`.

Quick Share is a trademark of Google. The mark in `quickshare.svg` is a tracing of Google's icon, and this project is not affiliated with Google.
