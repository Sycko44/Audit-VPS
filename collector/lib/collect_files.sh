#!/usr/bin/env bash

collect_files() {
  local out_root="$1"
  local manifest="${out_root}/manifests/files_manifest.csv"
  mkdir -p "${out_root}/manifests" "${out_root}/previews"

  echo 'path,type,size_bytes,owner,group,mode,mtime,sha256,preview_path' >"${manifest}"

  find /etc /root /home /var/www /srv /opt /usr/local \
    -type f 2>/dev/null | sed -n '1,5000p' | while IFS= read -r f; do
    [ -f "$f" ] || continue
    type_desc="$(file -b --mime-type "$f" 2>/dev/null || echo unknown)"
    size_b="$(stat -c '%s' "$f" 2>/dev/null || echo 0)"
    owner="$(stat -c '%U' "$f" 2>/dev/null || echo unknown)"
    group="$(stat -c '%G' "$f" 2>/dev/null || echo unknown)"
    mode="$(stat -c '%a' "$f" 2>/dev/null || echo unknown)"
    mtime="$(stat -c '%y' "$f" 2>/dev/null | tr ',' ';' || echo unknown)"
    sha="$(sha256sum "$f" 2>/dev/null | awk '{print $1}' || true)"
    preview=''

    case "$type_desc" in
      text/*|application/json|application/xml|application/x-sh)
        if [ "$size_b" -le 262144 ]; then
          rel="$(echo "$f" | sed 's#^/##; s#[^A-Za-z0-9._/-]#_#g')"
          preview="${out_root}/previews/${rel}.txt"
          mkdir -p "$(dirname "$preview")"
          head -n 80 "$f" >"$preview" 2>/dev/null || true
        fi
        ;;
    esac

    printf '%s,%s,%s,%s,%s,%s,%s,%s,%s\n' \
      "$f" "$type_desc" "$size_b" "$owner" "$group" "$mode" "$mtime" "$sha" "$preview" >>"${manifest}"
  done
}
