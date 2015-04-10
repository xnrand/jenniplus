#!/bin/sh
# SHOULD be posix-compatible.

log() {
  printf '\n[$%s] %s\n' "$applypatcheslogsuffix" "$*"
  "$@"
}

logcd() {
  local dir="$1"
  shift
  cd "$dir"
  printf '\n[$:%s] %s\n' "$dir" "$*"
  "$@"
  cd "$PDIR"
}

unset applypatcheslogsuffix
set -o errexit

PDIR="$(dirname "$(readlink -fn "$0")")"

printf '[=] stored in %s\n' "$PDIR"

cd $PDIR

log git submodule update --init

if ! [ -d jenniplus ] ; then
  log git clone jenni jenniplus
elif ! [ -d jenniplus/.git ] ; then
  printf '[?] "jenniplus" exists but is not a git repository'
else
  logcd jenniplus git checkout origin/master
  logcd jenniplus git pull origin master
fi

log cd jenniplus

for patch in ../patches/* ; do
  log git am "$patch"
done

printf '[=] applied patches successfully\n'
