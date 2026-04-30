#!/bin/bash
# Renomme toutes les photos et régénère photos.json
# Usage : ./rename.sh
cd "$(dirname "$0")"

for model in a2251 a2141; do
  for grade in a b c; do
    dir="images/$model/grade-$grade"
    [ -d "$dir" ] || continue
    i=1
    for file in $(ls "$dir" | grep -v '\.gitkeep' | sort); do
      ext="${file##*.}"
      new="photo${i}.${ext,,}"
      [ "$file" != "$new" ] && mv "$dir/$file" "$dir/$new"
      ((i++))
    done
  done
done

# Régénère photos.json
python3 - <<'EOF'
import os, json
data = {}
for model in ["a2251", "a2141"]:
    data[model] = {}
    for grade in ["a", "b", "c"]:
        d = f"images/{model}/grade-{grade}"
        files = sorted([f for f in os.listdir(d) if not f.startswith(".")]) if os.path.isdir(d) else []
        data[model][grade] = files
with open("photos.json", "w") as f:
    json.dump(data, f, indent=2)
EOF

echo "✓ Photos renommées et photos.json mis à jour"
echo "→ git add . && git commit -m 'Update photos' && git push"
