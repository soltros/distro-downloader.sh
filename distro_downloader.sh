#!/bin/bash

# Check if wget is installed
if ! [ -x "$(command -v wget)" ]; then
  echo 'Error: wget is not installed.' >&2
  exit 1
fi

# Check if dd is installed
if ! [ -x "$(command -v dd)" ]; then
  echo 'Error: dd is not installed.' >&2
  exit 1
fi

# GitHub URL of the distros.csv file
GITHUB_DISTROS_CSV_URL='https://raw.githubusercontent.com/soltros/distro-downloader.sh/main/distros.csv'

# Directory of the script
SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

update_distro_csv() {
  echo "Checking for updates..."
  wget -q -O "${SCRIPT_DIR}/distros.csv.tmp" "$GITHUB_DISTROS_CSV_URL"
  
  if ! diff -q "${SCRIPT_DIR}/distros.csv" "${SCRIPT_DIR}/distros.csv.tmp" > /dev/null; then
    echo "Updates found. Updating distros.csv..."
    mv "${SCRIPT_DIR}/distros.csv.tmp" "${SCRIPT_DIR}/distros.csv"
  else
    echo "No updates found."
    rm "${SCRIPT_DIR}/distros.csv.tmp"
  fi
}

download_distro() {
  local url=$1
  local file_name=$2
  wget -c "$url" -O "$HOME/Downloads/$file_name"
}

list_distros() {
  echo "Available distributions:"
  tail -n +2 "${SCRIPT_DIR}/distros.csv" | cut -d',' -f1
}

flash_to_usb() {
  local iso_file=$1
  echo "Available USB drives:"
  lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL
  read -p "Enter the device name (e.g. /dev/sdb): " device
  dd if="$iso_file" of="$device" bs=4M status=progress oflag=sync
  echo "Flashing complete. Please verify the USB drive."
}

# Update distros.csv from GitHub before doing anything else
update_distro_csv

# Call list_distros if no arguments are provided
if [ "$#" -eq 0 ]; then
  list_distros
  exit 0
fi

distro=$1

# Read the external file and find the matching distribution
while IFS=, read -r distribution version url; do
  if [[ "$distro" == "$distribution" ]]; then
    file_name="$distribution-$version.iso"
    download_distro "$url" "$file_name"
    flash_to_usb "$HOME/Downloads/$file_name"
    exit 0
  fi
done < "${SCRIPT_DIR}/distros.csv"

echo "Unsupported distribution: $distro"
exit 1
