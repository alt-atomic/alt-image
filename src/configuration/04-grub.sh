#!/bin/bash -efu
#
# GRUB and EFI bootloader configuration for Alt Linux
# This script prepares EFI files for bootupd
#
echo "::group:: ===$(basename "$0")==="

BOOTUPD_UPDATES_DIR="/usr/lib/bootupd/updates"
EFI_SOURCE_DIR="/usr/lib64/efi"
SHIM_SIGNED_DIR="/usr/lib/shim"
SHIM_UNSIGNED_DIR="/usr/share/shim/16.1"

message() {
    printf '%s: %s\n' "${0##*/}" "$*" >&2
}

EFI_CERT=""
for cert_name in altlinux alt linux; do
    if [ -f "/etc/pki/uefi/${cert_name}.cer" ]; then
        EFI_CERT="$cert_name"
        message "Found EFI certificate: /etc/pki/uefi/${cert_name}.cer"
        break
    fi
done

if [ -z "$EFI_CERT" ]; then
    message "No EFI certificate found in /etc/pki/uefi/ - Secure Boot will be disabled"
else
    message "Secure Boot enabled with certificate: $EFI_CERT"
fi

message "Setting up GRUB EFI files for bootupd"

mkdir -p "$BOOTUPD_UPDATES_DIR/EFI/BOOT"
mkdir -p "$BOOTUPD_UPDATES_DIR/EFI/altlinux"

# Function to copy EFI file if it exists
copy_efi_file() {
    local src="$1"
    local dest="$2"
    local desc="$3"
    
    if [ -f "$src" ]; then
        cp -pf "$src" "$dest"
        message "Copied $desc: $src -> $dest"
        return 0
    else
        message "WARNING: $desc not found at $src"
        return 1
    fi
}

# Function to copy EFI certificates for Secure Boot
copy_efi_certificates() {
    [ -n "$EFI_CERT" ] || return 0
    
    local keyfile="/etc/pki/uefi/$EFI_CERT.cer"
    local cert_dest="$BOOTUPD_UPDATES_DIR/EFI/enroll"
    
    if [ -s "$keyfile" ]; then
        mkdir -p "$cert_dest"
        cp -pf "$keyfile" "$cert_dest/"
        message "Copied EFI certificate: $keyfile -> $cert_dest/"
        return 0
    else
        message "WARNING: EFI certificate not found at $keyfile"
        return 1
    fi
}

# Setup BOOT directory (fallback EFI boot files)
message "Setting up EFI/BOOT directory..."

# Copy EFI certificates if present (for Secure Boot)
copy_efi_certificates

# Determine which shim set to use: signed (with certificates) or unsigned
if [ -n "$EFI_CERT" ] && [ -f "$SHIM_SIGNED_DIR/shimx64.efi.signed" ]; then
    message "Using signed shim set for Secure Boot"
    SHIM_DIR="$SHIM_SIGNED_DIR"
    SHIM_SUFFIX=".signed"
    CSV_DIR="$SHIM_SIGNED_DIR"
elif [ -f "$SHIM_UNSIGNED_DIR/x64/shimx64.efi" ]; then
    message "Using unsigned shim set"
    SHIM_DIR="$SHIM_UNSIGNED_DIR"
    SHIM_SUFFIX=""
    CSV_DIR="$SHIM_UNSIGNED_DIR"
else
    message "No shim found, using GRUB directly"
    SHIM_DIR=""
fi

# Primary bootloader - try shim first, fallback to grub
if [ -n "$SHIM_DIR" ]; then
    if [ -n "$SHIM_SUFFIX" ]; then
        # Signed shim
        copy_efi_file "$SHIM_DIR/shimx64.efi$SHIM_SUFFIX" "$BOOTUPD_UPDATES_DIR/EFI/BOOT/BOOTX64.EFI" "signed shim bootloader"
        copy_efi_file "$EFI_SOURCE_DIR/grubx64.efi" "$BOOTUPD_UPDATES_DIR/EFI/BOOT/grubx64.efi" "GRUB EFI loader"
        copy_efi_file "$SHIM_DIR/mmx64.efi$SHIM_SUFFIX" "$BOOTUPD_UPDATES_DIR/EFI/BOOT/mmx64.efi" "signed MokManager"
        copy_efi_file "$SHIM_DIR/fbx64.efi$SHIM_SUFFIX" "$BOOTUPD_UPDATES_DIR/EFI/BOOT/fbx64.efi" "signed fallback loader"
        
        # ia32 support
        if copy_efi_file "$SHIM_DIR/shimia32.efi$SHIM_SUFFIX" "$BOOTUPD_UPDATES_DIR/EFI/BOOT/bootia32.efi" "signed ia32 shim"; then
            copy_efi_file "$SHIM_DIR/mmia32.efi$SHIM_SUFFIX" "$BOOTUPD_UPDATES_DIR/EFI/BOOT/mmia32.efi" "signed ia32 MokManager"
            copy_efi_file "$SHIM_DIR/fbia32.efi$SHIM_SUFFIX" "$BOOTUPD_UPDATES_DIR/EFI/BOOT/fbia32.efi" "signed ia32 fallback loader"
        fi
    else
        # Unsigned shim
        copy_efi_file "$SHIM_DIR/x64/shimx64.efi" "$BOOTUPD_UPDATES_DIR/EFI/BOOT/BOOTX64.EFI" "unsigned shim bootloader"
        copy_efi_file "$EFI_SOURCE_DIR/grubx64.efi" "$BOOTUPD_UPDATES_DIR/EFI/BOOT/grubx64.efi" "GRUB EFI loader"
        copy_efi_file "$SHIM_DIR/x64/mmx64.efi" "$BOOTUPD_UPDATES_DIR/EFI/BOOT/mmx64.efi" "unsigned MokManager"
        copy_efi_file "$SHIM_DIR/x64/fbx64.efi" "$BOOTUPD_UPDATES_DIR/EFI/BOOT/fbx64.efi" "unsigned fallback loader"
        
        # ia32 support
        if copy_efi_file "$SHIM_DIR/ia32/shimia32.efi" "$BOOTUPD_UPDATES_DIR/EFI/BOOT/bootia32.efi" "unsigned ia32 shim"; then
            copy_efi_file "$SHIM_DIR/ia32/mmia32.efi" "$BOOTUPD_UPDATES_DIR/EFI/BOOT/mmia32.efi" "unsigned ia32 MokManager"
            copy_efi_file "$SHIM_DIR/ia32/fbia32.efi" "$BOOTUPD_UPDATES_DIR/EFI/BOOT/fbia32.efi" "unsigned ia32 fallback loader"
        fi
    fi
else
    # No shim available, use GRUB directly
    copy_efi_file "$EFI_SOURCE_DIR/grubx64.efi" "$BOOTUPD_UPDATES_DIR/EFI/BOOT/BOOTX64.EFI" "GRUB EFI loader (direct boot)"
fi

# Setup vendor directory (altlinux)
message "Setting up EFI/altlinux directory..."

# Copy all required files to altlinux directory (same set as BOOT)
copy_efi_file "$EFI_SOURCE_DIR/grubx64.efi" "$BOOTUPD_UPDATES_DIR/EFI/altlinux/grubx64.efi" "vendor GRUB loader"

if [ -n "$SHIM_DIR" ]; then
    if [ -n "$SHIM_SUFFIX" ]; then
        # Signed shim set for altlinux
        copy_efi_file "$SHIM_DIR/shimx64.efi$SHIM_SUFFIX" "$BOOTUPD_UPDATES_DIR/EFI/altlinux/shimx64.efi" "signed vendor shim loader"
        copy_efi_file "$SHIM_DIR/mmx64.efi$SHIM_SUFFIX" "$BOOTUPD_UPDATES_DIR/EFI/altlinux/mmx64.efi" "signed vendor MokManager"
        copy_efi_file "$SHIM_DIR/fbx64.efi$SHIM_SUFFIX" "$BOOTUPD_UPDATES_DIR/EFI/altlinux/fbx64.efi" "signed vendor fallback loader"
    else
        # Unsigned shim set for altlinux
        copy_efi_file "$SHIM_DIR/x64/shimx64.efi" "$BOOTUPD_UPDATES_DIR/EFI/altlinux/shimx64.efi" "unsigned vendor shim loader"
        copy_efi_file "$SHIM_DIR/x64/mmx64.efi" "$BOOTUPD_UPDATES_DIR/EFI/altlinux/mmx64.efi" "unsigned vendor MokManager"
        copy_efi_file "$SHIM_DIR/x64/fbx64.efi" "$BOOTUPD_UPDATES_DIR/EFI/altlinux/fbx64.efi" "unsigned vendor fallback loader"
    fi
fi

# Copy CSV metadata files (use appropriate directory)
if [ -n "$SHIM_SUFFIX" ]; then
    copy_efi_file "$CSV_DIR/BOOTX64.CSV" "$BOOTUPD_UPDATES_DIR/EFI/altlinux/BOOTX64.CSV" "boot entry metadata"
    copy_efi_file "$CSV_DIR/BOOTIA32.CSV" "$BOOTUPD_UPDATES_DIR/EFI/altlinux/BOOTIA32.CSV" "ia32 boot entry metadata"
else
    copy_efi_file "$CSV_DIR/x64/BOOTX64.CSV" "$BOOTUPD_UPDATES_DIR/EFI/altlinux/BOOTX64.CSV" "boot entry metadata"
    copy_efi_file "$CSV_DIR/ia32/BOOTIA32.CSV" "$BOOTUPD_UPDATES_DIR/EFI/altlinux/BOOTIA32.CSV" "ia32 boot entry metadata"
fi

# Setup GRUB modules
message "Setting up GRUB modules and resources..."

# Set appropriate permissions
message "Setting file permissions..."
find "$BOOTUPD_UPDATES_DIR" -type f -exec chmod 644 {} \;

# Display summary
message "GRUB EFI setup completed successfully"
message "Files created in: $BOOTUPD_UPDATES_DIR/EFI/"

# Show what we created
if command -v tree >/dev/null 2>&1; then
    message "Directory structure:"
    tree "$BOOTUPD_UPDATES_DIR/EFI" 2>/dev/null || ls -laR "$BOOTUPD_UPDATES_DIR/EFI"
else
    message "Created files:"
    find "$BOOTUPD_UPDATES_DIR/EFI" -type f | sort
fi

# Generate JSON metadata files for bootupd
generate_bootupd_metadata() {
    local component="$1"
    local version="$2"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    local json_file="$BOOTUPD_UPDATES_DIR/${component}.json"
    
    cat > "$json_file" << EOF
{
  "timestamp": "$timestamp",
  "version": "$version",
  "description": "Initial from core image"
}
EOF
    
    message "Generated $component metadata: $json_file"
}

# Generate EFI component metadata
message "Generating bootupd metadata files..."

# Get package versions for Alt Linux
EFI_VERSION=""
BIOS_VERSION=""

# Try to get shim and grub versions from rpm
if command -v rpm >/dev/null 2>&1; then
    SHIM_VERSION=$(rpm -q shim-signed 2>/dev/null | head -1 || echo "shim-unknown")
    GRUB_EFI_VERSION=$(rpm -q grub-efi 2>/dev/null | head -1 || echo "grub-efi-unknown")
    GRUB_PC_VERSION=$(rpm -q grub-pc 2>/dev/null | head -1 || echo "grub-pc-unknown")
    
    EFI_VERSION="${GRUB_EFI_VERSION},${SHIM_VERSION}"
    BIOS_VERSION="${GRUB_PC_VERSION}"
else
    # Fallback versions
    EFI_VERSION="grub-efi-alt-linux,shim-alt-linux"
    BIOS_VERSION="grub-pc-alt-linux"
fi

# Generate metadata files
generate_bootupd_metadata "EFI" "$EFI_VERSION"
generate_bootupd_metadata "BIOS" "$BIOS_VERSION"

cat << EOF > /usr/sbin/update-grub
#!/bin/sh -e

bootupctl update
EOF
chmod +x /usr/sbin/update-grub

echo "::endgroup::"
