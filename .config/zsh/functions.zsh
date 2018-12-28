# FileName:     $XDG_CONFIG_HOME/zsh/functions
# vim:fenc=utf-8:nu:ai:si:et:ts=4:sw=4:ft=zsh:

# Extract Files
x() {
  if [ -f $1 ] ; then
      case $1 in
          *.tar.bz2)   tar xvjf $1    ;;
          *.tar.gz)    tar xvzf $1    ;;
          *.tar.xz)    tar xvJf $1    ;;
          *.bz2)       bunzip2 $1     ;;
          *.rar)       unrar x $1     ;;
          *.gz)        gunzip $1      ;;
          *.tar)       tar xvf $1     ;;
          *.tbz2)      tar xvjf $1    ;;
          *.tgz)       tar xvzf $1    ;;
          *.zip)       unzip $1       ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1        ;;
          *.xz)        unxz $1        ;;
          *.exe)       cabextract $1  ;;
          *)           echo "\`$1': unrecognized file compression" ;;
      esac
  else
      echo "\`$1' is not a valid file"
  fi
}

# check history
zhist() { grep -i "$1" "$ZDOTDIR"/histfile ;}

# hostblocking
urlcheck() { sudo hostsblock-urlcheck "$1" ;}

# ssh and run application
shux() { ssh "$1" -t LANG=en_EN.utf-8 tmux a -d ;}

# grab pid
pids() { ps aux | grep "$1" ;}

# paste to sprunge
sprung() { curl -F "sprunge=<-" http://sprunge.us <"$1" ;}

# check pacman's log
paclog() { tail -n"$1" /var/log/pacman.log ;}

# scan dir for thumbs
sx() { sxiv -trq "$@" 2>/dev/null ;}

# Follow copied and moved files to destination directory
goto() { [ -d "$1" ] && cd "$1" || cd "$(dirname "$1")"; }
cpf() { cp "$@" && goto "$_"; }
mvf() { mv "$@" && goto "$_"; }

# External IP
whatismyip() { printf "%s\n" $(curl -s  http://ifconfig.me/) ;}

# attach tmux to existing session
mux() { [[ -z "$TMUX" ]] && { tmux attach -d || tmux -f $XDG_CONFIG_HOME/tmux/conf new -s secured ;} }

# International timezone
zone() { TZ="$1"/"$2" date; }
zones() { ls /usr/share/zoneinfo/"$1" ;}

# Nice mount output
nmount() { (echo "DEVICE PATH TYPE FLAGS" && mount | awk '$2=$4="";1') | column -t; }

# Print man pages 
manp() { man -t "$@" | lpr -pPrinter; }

# Create pdf of man page - requires ghostscript and mimeinfo
manpdf() { man -t "$@" | ps2pdf - /tmp/manpdf_$1.pdf && xdg-open /tmp/manpdf_$1.pdf ;}

# wifi connect

# VPN
vpnon() { sudo vpnc "$1" ; }
vpnoff() { sudo vpnc-disconnect ; }
vpnup() { pgrep vpnc >/dev/null && printf '%s\n' "Connected…" || printf '%s\n' "VPN down!" ; }

## simple notes
#n() {
#  local files
#  files=(${@/#/$HOME/notes/})
#  ${EDITOR:-vi} $files
#}
#
## TAB completion for notes
#_notes() {
#    _files -g "*" -W $HOME/notes
#}
#compdef _notes n

# list notes
nls() {
  tree -CR --noreport $HOME/.notes | awk '{
      if (NF==1) print $1;
      else if (NF==2) print $2;
      else if (NF==3) printf "  %s\n", $3
    }'
}

# systemd
status() { sudo systemctl status $1; }
start() { sudo systemctl start $1; status $1; }
stop() { sudo systemctl stop $1; status $1; } 
restart() { sudo systemctl restart $1; status $1; } 
enabled() { sudo systemctl enable $1; listd; }
disabled() { sudo systemctl disable $1; listd; }

# Some quick Perl-hacks aka /useful/ oneliner
bew() { perl -le 'print unpack "B*","'$1'"' }
web() { perl -le 'print pack "B*","'$1'"' }
hew() { perl -le 'print unpack "H*","'$1'"' }
weh() { perl -le 'print pack "H*","'$1'"' }
pversion()    { perl -M$1 -le "print $1->VERSION" } # i. e."pversion LWP -> 5.79"
getlinks ()   { perl -ne 'while ( m/"((www|ftp|http):\/\/.*?)"/gc ) { print $1, "\n"; }' $* }
gethrefs ()   { perl -ne 'while ( m/href="([^"]*)"/gc ) { print $1, "\n"; }' $* }
getanames ()  { perl -ne 'while ( m/a name="([^"]*)"/gc ) { print $1, "\n"; }' $* }
getforms ()   { perl -ne 'while ( m:(\</?(input|form|select|option).*?\>):gic ) { print $1, "\n"; }' $* }
getstrings () { perl -ne 'while ( m/"(.*?)"/gc ) { print $1, "\n"; }' $*}
getanchors () { perl -ne 'while ( m/«([^«»\n]+)»/gc ) { print $1, "\n"; }' $* }
showINC ()    { perl -e 'for (@INC) { printf "%d %s\n", $i++, $_ }' }
vimpm ()      { vim `perldoc -l $1 | sed -e 's/pod$/pm/'` }
vimhelp ()    { vim -c "help $1" -c on -c "au! VimEnter *" }

# print hex value of a number
hex() {
    emulate -L zsh
    if [[ -n "$1" ]]; then
        printf "%x\n" $1
    else
        print 'Usage: hex <number-to-convert>'
        return 1
    fi
}

# variation of our manzsh() function; pick you poison:
manzsh()  { /usr/bin/man zshall |  most +/"$1" ; }

# Switching shell safely and efficiently? http://www.zsh.org/mla/workers/2001/msg02410.html
bash() {
    NO_SWITCH="yes" command bash "$@"
}
restart () {
    exec $SHELL $SHELL_ARGS "$@"
}

# Handy functions for use with the (e::) globbing qualifier (like nt)
contains() { grep -q "$*" $REPLY }
sameas() { diff -q "$*" $REPLY &>/dev/null }
ot () { [[ $REPLY -ot ${~1} ]] }

# get_ic() - queries imap servers for capabilities; real simple. no imaps
ic_get() {
    emulate -L zsh
    local port
    if [[ ! -z $1 ]] ; then
        port=${2:-143}
        print "querying imap server on $1:${port}...\n";
        print "a1 capability\na2 logout\n" | nc $1 ${port}
    else
        print "usage:\n  $0 <imap-server> [port]"
    fi
}

# List all occurrences of programm in current PATH
plap() {
    emulate -L zsh
    if [[ $# = 0 ]] ; then
        echo "Usage:    $0 program"
        echo "Example:  $0 zsh"
        echo "Lists all occurrences of program in the current PATH."
    else
        ls -l ${^path}/*$1*(*N)
    fi
}

# Find out which libs define a symbol
lcheck() {
    if [[ -n "$1" ]] ; then
        nm -go /usr/lib/lib*.a 2>/dev/null | grep ":[[:xdigit:]]\{8\} . .*$1"
    else
        echo "Usage: lcheck <function>" >&2
    fi
}

# Download a file and display it locally
uopen() {
    emulate -L zsh
    if ! [[ -n "$1" ]] ; then
        print "Usage: uopen \$URL/\$file">&2
        return 1
    else
        FILE=$1
        MIME=$(curl --head $FILE | \
               grep Content-Type | \
               cut -d ' ' -f 2 | \
               cut -d\; -f 1)
        MIME=${MIME%$'\r'}
        curl $FILE | see ${MIME}:-
    fi
}

# Memory overview
memusage() {
    ps aux | awk '{if (NR > 1) print $5;
                   if (NR > 2) print "+"}
                   END { print "p" }' | dc
}

# Grep directory pager with color
gp()
{
    grep --color=always -rnv $1 | less -R
}

up() {
    COUNTER=$1
    while [[ $COUNTER -gt 0 ]]
    do
        UP="${UP}../"
        COUNTER=$(( $COUNTER -1 ))
    done
    cd $UP
    unset UP
    pwd
}

p(){
    pwgen -sy1 $1 $((2**16)) \
        | awk -v n=$((RANDOM % (2**16))) 'NR==n'
}
