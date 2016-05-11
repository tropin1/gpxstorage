#!/bin/bash
# расчитывает текущую версию master

git pull origin master --tags > /dev/null 2> /dev/null
ver="$(head -n 1 README.md | grep -oE '^v([0-9]+\.?){3}' | sed -e 's/\.$//g')"
last=$(git rev-list $ver..HEAD --count)

ver="$ver.$(($last + 1))"
echo $ver > public/ver.txt
txt="$ver\n$(tail -n +2 README.md)"

echo -e "$txt" > README.md