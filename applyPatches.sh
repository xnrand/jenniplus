#!/bin/bash

_ensure() {
  local currline="$1"
  shift
  if $@ ; then :
  else
    local exitcode="$?"
    if [[ "$1" == "_log" ]] || [[ "$1" == "_logcd" ]] ; then
      shift 2
    fi
    printf '[?] line %s: Error: "%s" returned exit code %s\n' "$currline" "$*" "$exitcode" 1>&2
    exit 1
  fi
}
unalias -a
alias ensure='_ensure "$LINENO"'
alias ensurec='_ensure "$currline"'
alias log='ensure _log "$LINENO"'
alias logcd='ensure _logcd "$LINENO"'
shopt -s expand_aliases

_log() {
  shift
  printf '\n[$] %s\n' "$*"
  "$@"
}

_logcd() {
  local currline="$1"
  shift
  local dir="$1"
  shift
  ensurec cd "$dir"
  printf '\n[$:%s] %s\n' "$dir" "$*"
  "$@"
  local returncode="$?"
  ensurec cd "$PDIR"
  return "$returncode"
}

PDIR="$(dirname "$(readlink -fn "$0")")"

printf '[=] stored in %s\n' "$PDIR"

ensure cd $PDIR

log git submodule update --init
logcd jenni git checkout -B plus

if ! [[ -d jenniplus ]] ; then
  log git clone jenni jenniplus
  logcd jenniplus git checkout -q origin/plus
elif ! [[ -d jenniplus/.git ]] ; then
  printf '\n[?] line %s: "jenniplus" exists but is not a git repository\n' "$LINENO"
  exit 1
else
  logcd jenniplus git checkout -B origin/plus-old
  logcd jenniplus git fetch -f origin plus:plus
  logcd jenniplus git checkout plus
fi

for patch in patches/* ; do
  logcd jenniplus git am ../"$patch"
done

printf '\n[=] applied patches successfully\n'
