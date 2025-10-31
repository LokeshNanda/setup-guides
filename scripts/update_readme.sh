#!/usr/bin/env bash
set -euo pipefail

# Rebuilds README.md with links to every markdown page under docs/.
# Groups links by the top-level directory beneath docs.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
README_PATH="$ROOT_DIR/README.md"
DOCS_DIR="$ROOT_DIR/docs"

if [[ ! -f "$README_PATH" ]]; then
  echo "README not found at $README_PATH" >&2
  exit 1
fi

if [[ ! -d "$DOCS_DIR" ]]; then
  echo "Docs directory not found at $DOCS_DIR" >&2
  exit 1
fi

mapfile -t markdown_files < <(find "$DOCS_DIR" -type f -name '*.md' | sort)

if [[ ${#markdown_files[@]} -eq 0 ]]; then
  echo "No markdown files found under $DOCS_DIR" >&2
  exit 0
fi

to_title_case() {
  local phrase="$1"
  phrase="${phrase//_/ }"
  phrase="${phrase//-/ }"
  awk '{
    for (i = 1; i <= NF; ++i) {
      $i = tolower($i)
      $i = toupper(substr($i,1,1)) substr($i,2)
    }
    printf "%s", $0
  }' <<<"$phrase"
}

page_title() {
  local file_path="$1"
  local heading
  heading="$(grep -m 1 '^# ' "$file_path" | sed 's/^#\s\+//')"
  if [[ -n "$heading" ]]; then
    printf '%s' "$heading"
    return
  fi
  local fallback
  fallback="$(basename "$file_path" .md)"
  to_title_case "$fallback"
}

declare -A grouped_files
declare -A seen_category
categories=()

for file in "${markdown_files[@]}"; do
  rel_path="${file#$DOCS_DIR/}"
  category="."
  remainder="$rel_path"
  if [[ "$rel_path" == */* ]]; then
    category="${rel_path%%/*}"
    remainder="${rel_path#*/}"
  fi

  if [[ -z ${seen_category["$category"]+x} ]]; then
    categories+=("$category")
    seen_category["$category"]=1
  fi

  if [[ -z ${grouped_files["$category"]+x} ]]; then
    grouped_files["$category"]="$remainder"
  else
    grouped_files["$category"]+=$'\n'"$remainder"
  fi
done

tmp_readme="$(mktemp)"
cleanup() {
  rm -f "$tmp_readme"
}
trap cleanup EXIT

{
  printf '# Setup Guides\n'
  printf 'Useful guidebook in markdown format.\n\n'
  printf '[Website Link](https://lokeshnanda.github.io/setup-guides/)\n\n'
  printf '# Pre-Requisite\n'
  printf 'Update the markdown files and run the shell script `sh scripts/update_readme.sh` \nThis will update the readme with the latest content.\n\n'
  printf '## Contents\n\n'

  if [[ -n ${grouped_files["."]+x} ]]; then
    while IFS= read -r slug; do
      [[ -z "$slug" ]] && continue
      file_path="$DOCS_DIR/$slug"
      title="$(page_title "$file_path")"
      printf -- '- [%s](./docs/%s)\n' "$title" "$slug"
    done <<<"${grouped_files["."]}"
    printf '\n'
  fi

  for category in "${categories[@]}"; do
    [[ "$category" == "." ]] && continue
    pretty_category="$(to_title_case "$category")"
    printf -- '- **%s**\n' "$pretty_category"
    while IFS= read -r slug; do
      [[ -z "$slug" ]] && continue
      file_path="$DOCS_DIR/$category/$slug"
      title="$(page_title "$file_path")"
      printf '  - [%s](./docs/%s/%s)\n' "$title" "$category" "$slug"
    done <<<"${grouped_files["$category"]}"
    printf '\n'
  done
} >"$tmp_readme"

mv "$tmp_readme" "$README_PATH"
trap - EXIT
