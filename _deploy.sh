#!/bin/sh

set -e

[ -z "${GITHUB_TOKEN}" ] && exit 0
[ "${TRAVIS_BRANCH}" != "master" ] && exit 0

git config --global user.email "seanhardison@gmail.com"
git config --global user.name "Sean Hardison"

git clone -b gh-pages https://${GITHUB_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git pkg-output
cd pkg-output
git add --all *
git commit -m "Package update" || true
git push -q origin master
