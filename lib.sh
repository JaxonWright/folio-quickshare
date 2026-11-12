# Sourced by devices and send, which Folio runs in the plugin's folder.
# quickshare_bin prints the quickshare to run: the release this plugin pins,
# downloaded into bin/ on first use, so updating the plugin moves both.

QUICKSHARE_VERSION=0.2.0

quickshare_bin() {
  arch=$(uname -m)
  case $arch in
    x86_64) sum=316541022af101b755a98a23ecb4d3d5b6e0dabe97e80f61f0275d317782b184 ;;
    aarch64) sum=b95515244e9ccbc40c7158acae3026fe06e4b5a3a230e19e5764884c67b3eada ;;
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
