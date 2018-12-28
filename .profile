# FileName:     ~/.profile
# vim:fenc=utf-8:nu:ai:si:et:ts=4:sw=4:ft=sh:

source /etc/profile

[[ "$XDG_CACHE_HOME" ]] || export XDG_CACHE_HOME="$HOME"/.cache
[[ "$XDG_CONFIG_HOME" ]] || export XDG_CONFIG_HOME="$HOME"/.config
[[ "$XDG_DATA_HOME" ]] || export XDG_DATA_HOME="$HOME"/.local/share

# setup environment
# export GPGKEY=
export ANDROID_HOME="/opt/android-sdk"
export BROWSER="/usr/bin/chromium"
export EDITOR="vim"
export FCEDIT="vim"
export LC_ALL=
export LC_COLLATE="C"
export LESSHISTFILE=-
export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"
export LESS=' -R '
export SYSTEMD_PAGER="/usr/bin/less" 
export VISUAL="$EDITOR"
export GNUPGHOME="$HOME"/.gnupg

# XDG base conf
source "$(dircolors "$XDG_CONFIG_HOME"/dircolors)" 2&> /dev/null
export ELINKS_CONFDIR="$XDG_CONFIG_HOME"/elinks
export GIMP2_DIRECTORY="$XDG_CONFIG_HOME"/gimp
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export IMAPFILTER_HOME=/home/lorenz/.config/imapfilter
export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc
export IPYTHONDIR="$XDG_CONFIG_HOME"/ipython
export MATHEMATICA_USERBASE="$XDG_CONFIG_HOME"/mathematica
export NMBGIT="$XDG_DATA_HOME"/notmuch/nmbug
export NOTMUCH_CONFIG="$XDG_CONFIG_HOME"/notmuch/notmuchrc
export SOURCE_HIGHLIGHT_DATADIR="$XDG_CONFIG_HOME"/source_highlight
export TERMINFO="$XDG_DATA_HOME"/terminfo 
export TERMINFO_DIRS="$XDG_DATA_HOME"/terminfo:/usr/share/terminfo
export WINEPREFIX="$XDG_DATA_HOME"/wine
export XAUTHORITY="$XDG_RUNTIME_DIR"/xauthority
export XINITRC="$XDG_CONFIG_HOME"/X11/xinitrc

# node settings
#export npm_config_cache="$XDG_CACHE_HOME"/npm
#export npm_config_prefix="$HOME"/.node_modules
#export npm_config_userconfig="$XDG_CONFIG_HOME"/npmrc

# ruby settings
if [[ -e /usr/share/chruby ]]; then
    source /usr/share/chruby/{chruby,auto}.sh
    chruby $(<"$XDG_CONFIG_HOME"/ruby-version)
fi

# java settings
export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=false'

# GnuPG
[ -z "$(pgrep 'gpg-agent')" ] && eval "$(gpg-agent --daemon --enable-ssh-support)"
export SSH_AUTH_SOCK   # enable gpg-agent for ssh

