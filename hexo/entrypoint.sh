#!/bin/sh

rm -rf source/*
rm -rf source/.git
rm -rf source/.gitkeep
rm -rf source/.gitignore

git clone $ARTICLE_REP source/

if [ ! -d "./themes/$THEME_NAME" ]; then
    git clone $THEME_REP themes/$THEME_NAME
fi

package=`echo "$THEME_PKG" | awk -F ',' '{for(i=1;i<=NF;i++){printf " "$i}}'`
yarn add$package

chown 1000:1000 -R source/

exec "$@"
