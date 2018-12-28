#!/usr/bin/env sh
# FileName: $XDG_CONFIG_HOME/mutt/bin/conf.d.shf
# vim:fenc=utf-8:nu:ai:si:et:ts=4:sw=4:ft=sh

[[ ! $# -eq 1 ]] && >&2 echo "Fail conf. No args in conf.d.sh" && exit 1

list=`echo "$XDG_CONFIG_HOME"/mutt/"$1".d/* | \
	egrep -o "[0-9]{2}-[[:alpha:]]+\.muttrc"`

[[ ! $list ]] && >&2 echo "No files in $XDG_CONFIG_HOME/mutt/$1" &&  exit 1

for i in $list; do
	echo source "$XDG_CONFIG_HOME"/mutt/"$1".d/"$i"
done
