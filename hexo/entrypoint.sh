#!/bin/sh

rm -rf source/*
rm -rf source/.git
rm -rf source/.gitkeep
rm -rf themes/*

git clone https://github.com/lintmx/blog-archive source/
git clone https://github.com/lintmx/hexo-theme-tiny themes/tiny
npm install hexo-render-pug hexo-renderer-stylus --save

chown 1000:1000 -R source/

exec "$@"
