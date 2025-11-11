#!/bin/bash -e

# Create link for apm because of sqlite3 lost connection to DB
move_and_link_relative() {
  local target="$1"
  local destination="$2"

  mkdir -p "$(dirname "$destination")"

  mv "$target" "$destination"

  relative_path=$(realpath --relative-to="$target" "$destination")

  ln -s "$relative_path" "$target"

  return 0
}

move_and_link_relative "/var/lib/apm" "/usr/var/lib/apm"
