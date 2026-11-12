# Sourced by the plugin's commands, which run in the plugin's folder.
# quickshare_bin prints the quickshare to run: the release this plugin pins,
# downloaded into bin/ on first use, so updating the plugin moves both.

QUICKSHARE_VERSION=0.3.0

# Receiving runs as this systemd user service, so it keeps going after Folio
# closes and comes back at the next login. The folder it receives into is in
# $state/dir.
unit=folio-quickshare-receive.service
state=${XDG_STATE_HOME:-$HOME/.local/state}/folio-quickshare

# Prints the folder being received into, or fails when receiving is off.
receiving_dir() {
  systemctl --user is-active --quiet "$unit" && cat "$state/dir" 2>/dev/null
}

quickshare_bin() {
  arch=$(uname -m)
  case $arch in
    x86_64) sum=f180aa7ea34a9518727be1c3f849c627ecabb30edd7be31c2de9ab2697a26d5a ;;
    aarch64) sum=d97b79b96f0699cc8f78dfee5890fa6f3a2a65bccae8cfdcd65e7486d5158a05 ;;
    *)
      command -v quickshare && return
      echo "no quickshare release for $arch; build it and put it on PATH" >&2
      return 1 ;;
  esac
  bin="bin/quickshare-$QUICKSHARE_VERSION"
  if [ ! -x "$bin" ]; then
    mkdir -p bin || return 1
    # Folio kills a poll after 10 seconds, so a slow download resumes from
    # where the last poll left off instead of starting over.
    curl -fsSL -C - --max-time 6 -o "$bin.part" \
      "https://github.com/JaxonWright/quickshare/releases/download/v$QUICKSHARE_VERSION/quickshare-$arch-linux" || {
      echo "downloading quickshare $QUICKSHARE_VERSION hasn't finished; it continues on the next poll" >&2
      return 1
    }
    if ! echo "$sum  $bin.part" | sha256sum -c --status; then
      rm -f "$bin.part"
      echo "the downloaded quickshare $QUICKSHARE_VERSION failed its checksum" >&2
      return 1
    fi
    chmod 755 "$bin.part" && mv -f "$bin.part" "$bin" || return 1
  fi
  echo "$PWD/$bin"
}
