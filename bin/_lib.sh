# shellcheck shell=bash
# Shared helpers. Sourced by bin/* scripts.

REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")/.." && pwd)
export REPO_ROOT

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
info() { printf '%s\n' "$*"; }

# Detect the host platform: "darwin-arm64", "darwin-x86_64", "linux-x86_64", etc.
host_platform() {
  printf '%s-%s\n' "$(uname -s | tr '[:upper:]' '[:lower:]')" "$(uname -m)"
}

# Vagrant's architecture vocabulary: amd64 / arm64.
host_arch() {
  case "$(uname -m)" in
    arm64|aarch64) printf 'arm64\n' ;;
    x86_64|amd64)  printf 'amd64\n' ;;
    *)             printf '%s\n' "$(uname -m)" ;;
  esac
}

# Default box architecture for install/new. We always default to the host
# arch because cross-arch emulation under UTM/QEMU TCG on Apple Silicon is
# unstable (UTM.app frequently crashes when emulating x86_64). Use
# ARCH=amd64 (or VAGRANT_BOX_ARCH) only when you accept the tradeoff.
default_box_arch() {
  if [ -n "${ARCH:-}" ]; then printf '%s\n' "$ARCH"; return; fi
  if [ -n "${VAGRANT_BOX_ARCH:-}" ]; then printf '%s\n' "$VAGRANT_BOX_ARCH"; return; fi
  host_arch
}

# Pick the default Vagrant provider for this host.
#   $VAGRANT_DEFAULT_PROVIDER wins if set.
#   Apple Silicon  -> vmware_desktop (Fusion; free for personal use, supports amd64 emulation)
#   Intel macOS    -> virtualbox
#   Linux          -> libvirt if libvirtd present, else virtualbox
default_provider() {
  if [ -n "${VAGRANT_DEFAULT_PROVIDER:-}" ]; then
    printf '%s\n' "$VAGRANT_DEFAULT_PROVIDER"
    return
  fi
  case "$(host_platform)" in
    darwin-arm64)  printf 'vmware_desktop\n' ;;
    darwin-*)      printf 'virtualbox\n' ;;
    linux-*)
      if command -v virsh >/dev/null 2>&1; then
        printf 'libvirt\n'
      else
        printf 'virtualbox\n'
      fi ;;
    *)             printf 'virtualbox\n' ;;
  esac
}

# Read boxes.yaml. We avoid a yaml parser dep by using python3 (already required by Ansible).
read_catalog() {
  python3 - <<'PY'
import os, sys, yaml
with open(os.path.join(os.environ['REPO_ROOT'], 'boxes.yaml')) as f:
    print(yaml.safe_dump(yaml.safe_load(f)))
PY
}

# Resolve an OS id + provider to a box name. Exits non-zero (with a stderr
# message) if the entry is absent or blank.
# Usage: catalog_box ubuntu24 virtualbox
catalog_box() {
  python3 - "$1" "$2" <<'PY'
import os, sys, yaml
os_id, provider = sys.argv[1], sys.argv[2]
with open(os.path.join(os.environ['REPO_ROOT'], 'boxes.yaml')) as f:
    cat = yaml.safe_load(f)
if os_id not in cat:
    sys.exit(f"unknown os id: {os_id}")
boxes = cat[os_id].get('boxes') or {}
box = boxes.get(provider)
if not box:
    sys.exit(f"no box defined for {os_id} on provider {provider}")
print(box)
PY
}

catalog_field() {
  python3 - "$1" "$2" <<'PY'
import os, sys, yaml
os_id, field = sys.argv[1], sys.argv[2]
with open(os.path.join(os.environ['REPO_ROOT'], 'boxes.yaml')) as f:
    cat = yaml.safe_load(f)
print(cat[os_id][field])
PY
}

list_os_ids() {
  python3 - <<'PY'
import os, yaml
with open(os.path.join(os.environ['REPO_ROOT'], 'boxes.yaml')) as f:
    cat = yaml.safe_load(f)
for k in cat: print(k)
PY
}
