#!/bin/bash -eu
#
# Prepare signed EFI bootloader files for bootupd (ALT Atomic image).
#
set -euo pipefail

: "${ARCH:?ARCH is not set (expected x86_64 or aarch64)}"

DEST="${DEST:-/usr/lib/bootupd/updates}"     # bootupd payload root (EFI under DEST/EFI)
EFI_BIN="${EFI_BIN:-/usr/lib64/efi}"         # signed shim/grub/mm/fb (shim-signed, grub-efi)
CSV_SRC="${CSV_SRC:-/usr/lib/shim}"          # BOOT*.CSV (shim-signed)
CERT_SRC="${CERT_SRC:-/etc/pki/uefi}"        # MOK enrollment certificate
UPDATE_GRUB="${UPDATE_GRUB:-/usr/sbin/update-grub}"

msg() { printf '%s: %s\n' "${0##*/}" "$*" >&2; }
die() { msg "ERROR: $*"; exit 1; }
copy() {
    [ -f "$1" ] || die "required file not found: $1"
    cp -pf --remove-destination "$1" "$2"
}

case "$ARCH" in
    x86_64)  EFI=x64;  EFI_UP=X64;  IA32=ia32; IA32_UP=IA32 ;;
    aarch64) EFI=aa64; EFI_UP=AA64; IA32='';   IA32_UP='' ;;
    *)       die "unsupported architecture: $ARCH" ;;
esac
msg "architecture: $ARCH (EFI: $EFI)"

# Signed shim is mandatory — fail the build if shim-signed is not installed.
[ -f "$EFI_BIN/shim$EFI.efi" ] || \
    die "signed shim not found at $EFI_BIN/shim$EFI.efi — is shim-signed installed?"
msg "signed shim found, building Secure Boot bootloader set"

mkdir -p "$DEST/EFI/BOOT" "$DEST/EFI/altlinux"

# Vendor dir (EFI/altlinux): shim + grub + mm + fb + CSV.
copy "$EFI_BIN/shim$EFI.efi" "$DEST/EFI/altlinux/shim$EFI.efi"
copy "$EFI_BIN/grub$EFI.efi" "$DEST/EFI/altlinux/grub$EFI.efi"
copy "$EFI_BIN/mm$EFI.efi"   "$DEST/EFI/altlinux/mm$EFI.efi"
copy "$EFI_BIN/fb$EFI.efi"   "$DEST/EFI/altlinux/fb$EFI.efi"
copy "$CSV_SRC/BOOT$EFI_UP.CSV" "$DEST/EFI/altlinux/BOOT$EFI_UP.CSV"

# Removable-media dir (EFI/BOOT): shim as BOOT<arch>.EFI + grub + mm + fb.
copy "$EFI_BIN/shim$EFI.efi" "$DEST/EFI/BOOT/BOOT$EFI_UP.EFI"
copy "$EFI_BIN/grub$EFI.efi" "$DEST/EFI/BOOT/grub$EFI.efi"
copy "$EFI_BIN/mm$EFI.efi"   "$DEST/EFI/BOOT/mm$EFI.efi"
copy "$EFI_BIN/fb$EFI.efi"   "$DEST/EFI/BOOT/fb$EFI.efi"

# Secondary 32-bit set (ia32) for x86_64 machines with 32-bit UEFI firmware.
if [ -n "$IA32" ]; then
    copy "$EFI_BIN/shim$IA32.efi" "$DEST/EFI/BOOT/boot$IA32.efi"
    copy "$EFI_BIN/grub$IA32.efi" "$DEST/EFI/BOOT/grub$IA32.efi"
    copy "$EFI_BIN/mm$IA32.efi"   "$DEST/EFI/BOOT/mm$IA32.efi"
    copy "$EFI_BIN/fb$IA32.efi"   "$DEST/EFI/BOOT/fb$IA32.efi"
    copy "$CSV_SRC/BOOT$IA32_UP.CSV" "$DEST/EFI/altlinux/BOOT$IA32_UP.CSV"
fi

# MOK enrollment certificate (mandatory).
[ -s "$CERT_SRC/altlinux.cer" ] || die "MOK certificate not found: $CERT_SRC/altlinux.cer"
mkdir -p "$DEST/EFI/enroll"
copy "$CERT_SRC/altlinux.cer" "$DEST/EFI/enroll/altlinux.cer"
msg "enroll certificate: altlinux.cer"

find "$DEST/EFI" -type f -exec chmod 0644 {} +

write_meta() {
    printf '{\n  "timestamp": "%s",\n  "version": "%s"\n}\n' \
        "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$2" > "$DEST/$1.json"
    msg "metadata: $1.json ($2)"
}

shim_v=$(rpm -q shim-signed 2>/dev/null || echo shim-signed-unknown)
grub_efi_v=$(rpm -q grub-efi 2>/dev/null || echo grub-efi-unknown)
grub_pc_v=$(rpm -q grub-pc 2>/dev/null || echo grub-pc-unknown)
write_meta EFI  "$grub_efi_v,$shim_v"
write_meta BIOS "$grub_pc_v"

# Convenience wrapper for `bootupctl update`.
install -Dm0755 /dev/stdin "$UPDATE_GRUB" <<'EOF'
#!/bin/sh -e
exec /usr/bin/bootupctl update
EOF

msg "EFI bootloader files prepared in $DEST/EFI"
