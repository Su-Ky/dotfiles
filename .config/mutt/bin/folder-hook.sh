#!/usr/bin/env sh
# FileName: $XDG_CONFIG_HOME/mutt/bin/folder-hook.sh
# Auto make folder-hook

for i in `echo ~/.config/mutt/account.d/* | \
	egrep -o "[[:digit:]]{2}-[[:alpha:]]+\.muttrc" | rev | cut -c 8- | rev`;
do
	echo "folder-hook `echo $i | cut -c 4-`/* source $XDG_CONFIG_HOME/mutt/account.d/$i.muttrc"
done
