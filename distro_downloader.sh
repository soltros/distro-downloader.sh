#!/bin/bash

# Check if wget is installed
if ! [ -x "$(command -v wget)" ]; then
  echo 'Error: wget is not installed.' >&2
  exit 1
fi

download_distro() {
  local url=$1
  local file_name=$2
  wget -c "$url" -O "$HOME/Downloads/$file_name"
}

list_distros() {
  echo "Available distributions:"
  tail -n +2 distros.csv | cut -d',' -f1
}

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
    exit 0
  fi
done < distros.csv

echo "Unsupported distribution: $distro"
exit 1
