#!/usr/bin/env bash
set -euo pipefail

# Run tflint once per Terraform root (the nearest ancestor directory that has
# an environments/ subdirectory), passing every *.tfvars file found there as
# --var-file. Errors if no environments/ directory is reachable or it is empty.

find_terraform_root() {
  local dir="$1"
  while [[ "$dir" != "/" ]]; do
    if [[ -d "$dir/environments" ]]; then
      echo "$dir"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

all_roots=()

for file in "$@"; do
  file_dir=$(cd "$(dirname "$file")" && pwd)
  if ! root=$(find_terraform_root "$file_dir"); then
    echo "Error: no environments/ directory found for $file" >&2
    exit 1
  fi
  all_roots+=("$root")
done

overall_exit=0

while IFS= read -r root; do
  tfvars_files=()
  while IFS= read -r f; do
    tfvars_files+=("$f")
  done < <(find "$root/environments" -maxdepth 1 -name "*.tfvars" | sort)

  if [[ ${#tfvars_files[@]} -eq 0 ]]; then
    echo "Error: no *.tfvars files found in $root/environments" >&2
    exit 1
  fi

  var_file_args=()
  for tfvars in "${tfvars_files[@]}"; do
    var_file_args+=("--var-file=$tfvars")
  done

  tflint \
    --chdir="$root" \
    "${var_file_args[@]}" || overall_exit=$?
done < <(printf '%s\n' "${all_roots[@]}" | sort -u)

exit $overall_exit
