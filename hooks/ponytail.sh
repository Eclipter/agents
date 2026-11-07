#!/bin/sh
# Hook configs stay free of usernames and Node install paths.
# shortcut: nvm/fnm/volta are not searched; a downloaded node that cannot start stays installed, delete the prefix to retry.
set -eu

prefix="${XDG_DATA_HOME:-$HOME/.local/share}/ponytail/node"
PATH="/opt/homebrew/bin:/home/linuxbrew/.linuxbrew/bin:/usr/local/bin:$PATH:$prefix/bin"
export PATH

# Official nodejs.org builds. Bump the version and the sums together.
node_version=v26.13.0

install_node() {
  os=$(uname -s)
  arch=$(uname -m)
  if [ "$os" = "Linux" ] && ldd /bin/sh 2>&1 | grep -q musl; then
    echo "ponytail: musl builds are not installed; put node on PATH" >&2
    exit 1
  fi
  case "$os:$arch" in
    Linux:x86_64)
      triple=linux-x64
      sum=d28a96af6c38596f6d9d97c0ee531c13d238d757742387d1928de822d959e997
      ;;
    Linux:aarch64|Linux:arm64)
      triple=linux-arm64
      sum=406fe3fbde1c054adff8b297c16fdb5af6659db327c1ac8acd46b56ef1af9a92
      ;;
    Darwin:arm64)
      triple=darwin-arm64
      sum=6f5b3187d9df9fc007e881167905bc7d69ad26450ddc377c83d63256a2495b6e
      ;;
    Darwin:x86_64)
      triple=darwin-x64
      sum=8bd636bc981a92e1ab930c02340eece2076eb1aaf94d14e421cdeeddc1292298
      ;;
    *)
      echo "ponytail: no Node build for $os $arch" >&2
      exit 1
      ;;
  esac

  lock="$prefix.lock"
  mkdir -p "$(dirname "$prefix")"
  if ! mkdir "$lock" 2>/dev/null; then
    pid=$(cat "$lock/pid" 2>/dev/null || true)
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      i=0
      while [ "$i" -lt 110 ]; do
        if [ -x "$prefix/bin/node" ]; then
          return 0
        fi
        if ! kill -0 "$pid" 2>/dev/null; then
          break
        fi
        sleep 1
        i=$((i + 1))
      done
      if [ -x "$prefix/bin/node" ]; then
        return 0
      fi
      if kill -0 "$pid" 2>/dev/null; then
        echo "ponytail: Node install is still running" >&2
        exit 1
      fi
    fi
    rm -rf "$lock"
    mkdir "$lock" 2>/dev/null || {
      echo "ponytail: Node install is already running" >&2
      exit 1
    }
  fi
  echo $$ > "$lock/pid"

  tmp=
  trap 'rm -rf "$lock"; [ -n "$tmp" ] && rm -rf "$tmp"' EXIT
  tmp=$(mktemp -d)
  name="node-${node_version}-${triple}"
  archive="${name}.tar.xz"
  url="https://nodejs.org/dist/${node_version}/${archive}"
  curl -fsSL --retry 2 --max-time 90 -o "$tmp/$archive" "$url" || {
    echo "ponytail: could not download $url" >&2
    exit 1
  }
  if command -v sha256sum >/dev/null 2>&1; then
    got=$(sha256sum "$tmp/$archive" | awk '{print $1}')
  else
    got=$(shasum -a 256 "$tmp/$archive" | awk '{print $1}')
  fi
  if [ "$got" != "$sum" ]; then
    echo "ponytail: checksum mismatch for $archive" >&2
    exit 1
  fi
  tar -xf "$tmp/$archive" -C "$tmp"
  rm -rf "$prefix"
  mv "$tmp/$name" "$prefix"
  rm -rf "$tmp"
  tmp=
  rm -rf "$lock"
  trap - EXIT
}

cd "$(dirname "$0")" || exit 1
if ! command -v node >/dev/null 2>&1; then
  install_node
fi
exec node "$@"
