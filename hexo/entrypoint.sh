#!/bin/sh

rm -rf source/*
rm -rf source/.git
rm -rf source/.gitkeep
rm -rf source/.gitignore

theme_name = `echo -n "$THEME_REP" | sed 's/http.*\/\/.*\/.*\/\(.*\)\.git/\1/g'`

git clone $ARTICLE_REP source/

if [ ! -d "./themes/$theme_name"]; then
    git clone $THEME_REP themes/$theme_name
fi

package=`echo "$THEME_PKG" | awk -F ',' '{for(i=1;i<=NF;i++){printf " "$i}}'`
yarn add$package

chown 1000:1000 -R source/

exec "$@"
