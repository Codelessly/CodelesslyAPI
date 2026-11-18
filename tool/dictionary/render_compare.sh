#!/bin/bash
# tool/dictionary/render_compare.sh <dump folder>: after
#   dart run tool/dictionary_closure.dart --dump <dump folder> --words …
#   tool/codelessly render <dump folder>/code --out <dump folder>/out-code --sizes 1440x900,834x1112,390x844
# (from the SDK checkout beside this one; `tool/codelessly serve` first makes each render ~1 s).
# Render each dict/ screen at each size and compare it with the code/ capture
# of the same name and size (the render tool's --compare given a file: given
# a folder it finds no reference on Windows). Output: <dump>/compare.txt, a
# line per screen and size: the share of pixels that match, and the first
# row that differs (or `identical`).

SDK="${SDK:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../CodelesslySDK" && pwd)}"
D="${1:?dump folder}"
OUT="$D/compare.txt"
: > "$OUT"
for f in "$D"/dict/*.json; do
  s=$(basename "$f" .json)
  for size in 1440x900 834x1112 390x844; do
    ref="$D/out-code/$s@$size.png"
    if [ ! -f "$ref" ]; then echo "$s $size no-reference" >> "$OUT"; continue; fi
    log=$(bash "$SDK/tool/codelessly" render "$D/dict" --out "$D/out-dict" --screen "$s" --sizes "$size" --compare "$ref" 2>&1)
    line=$(echo "$log" | grep -E "^compare " | head -1)
    # The share is rounded: a short label of difference reads 100.0%. Whether
    # any pixel differs is the "first difference" line.
    first=$(echo "$log" | grep -E "first difference" | head -1 | sed 's/^ *//')
    echo "$s $size ${line:-no-compare-line} ${first:-identical}" >> "$OUT"
  done
done
echo done >> "$OUT"
