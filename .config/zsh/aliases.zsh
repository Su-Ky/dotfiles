# file: $XDG_CONFIG_HOME/zsh/aliases.zsh
# vim:fenc=utf-8:nu:ai:si:et:ts=4:sw=4:ft=zsh:

# Pipes and ends
# alias R='| tr A-z N-za-m'
alias '...'='../..'
alias '....'='../../..'
alias BG='& exit'
alias C='|wc -l'
alias G='|grep'
alias H='|head'
alias Hl=' --help |& less -r'
alias K='|keep'
alias L='|less'
alias LL='|& less -r'
alias M='|most'
alias N='&>/dev/null'
alias SL='| sort | less'
alias S='| sort'
alias T='|tail'
alias V='| vim -'
alias XC='| xclip'

# get top 10 shell commands:
alias top10='print -l ${(o)history%% *} | uniq -c | sort -nr | head -n 10'

# Execute \kbd{./configure}
alias CO="./configure"

# Execute \kbd{./configure --help}
alias CH="./configure --help"

# ignore ~/.ssh/known_hosts entries
alias insecssh='ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" -o "PreferredAuthentications=keyboard-interactive"'

## New commands 
alias dat='date "+%y%m%d"'
alias doc='xdg-open'
alias du1='du -ch --max-depth=1'
alias errcho='>&2 echo'
alias hist='history | grep'         # requires an argument
alias nohist='fc -p'                # Disable history
alias old="cd $OLDPWD"
alias O="old"
alias ports='ss -tulanp' 
alias ssoff='xset -dpms; xset s off'
alias sson='xset +dpms; xset s on'
alias reboot='systemctl reboot'
alias halt='systemctl poweroff'
alias clean='make clean & rm config.h'
alias psg='ps aux | grep -v "grep" | egrep'
alias cdtodo='cd ~/Documents/note/TODOS'

# Configs
alias cfgzsh="vim $XDG_CONFIG_HOME/zsh/.zshrc"
alias cfgalias="vim $XDG_CONFIG_HOME/zsh/aliases.zsh"
alias cfgfunct="vim $XDG_CONFIG_HOME/zsh/functions.zsh"

# Net 
if [ $UID -ne 0 ]; then
    alias ipt='sudo /usr/bin/iptables'
    # display all rules #
    alias iptl='ipt -L -n -v --line-numbers | column -t'
    alias iptlin='ipt -L INPUT -n -v --line-numbers | column -t'
    alias iptlout='ipt -L OUTPUT -n -v --line-numbers | column -t'
    alias iptlfw='ipt -L FORWARD -n -v --line-numbers | column -t'
    alias iptludp='ipt -L UDP -n -v --line-numbers | column -t'
    alias iptltcp='ipt -L TCP -n -v --line-numbers | column -t'
fi 

# systemd aliases and functions 
alias t3='sudo systemctl isolate multi-user.target'
alias t5='sudo systemctl isolate graphical.target'
alias listd='find /etc/systemd/system -mindepth 1 -type d | xargs ls -l --color'

# Safety features 
alias ln='ln -i'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
alias cls=' echo -ne "\033c"'       # clear screen for real (it does not work in Terminology)
alias rm='rm -I --preserve-root'
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'
alias :q=' exit'
alias :Q=' exit'
alias :x=' exit'
alias cd..='cd ..'

# Privileged access 
if [ $UID -ne 0 ]; then
    alias sudo='sudo '
    alias scat='sudo cat'
    alias svi='sudoedit'
    alias root='sudo -s'
    alias wifi='sudo wifi-menu' 
    alias smv='sudo mv'
    alias srm='sudo rm'
    alias netctl='sudo netctl'
    alias dh='netctl start dhcpcd'
    alias wh='netctl start wlp0s20u2-Arch56'
    alias wu='netctl start wlp0s20u2-wifi.ub.edu'
    alias eduroam='netctl start eduroam'
    alias docker='sudo docker'
fi

# Docker
alias docker-clean-unused='docker system prune --all --force --volumes'
alias docker-clean-all='docker stop $(docker container ls -a -q) && docker system prune -a -f --volumes'

# ls 
alias ls='ls -hF --color=auto'
alias lr='ls -R'                    # recursive ls
alias ll='ls -l'
alias la='ll -A'
alias lx='ll -BX'                   # sort by extension
alias lz='ll -rS'                   # sort by size
alias lt='ll -rt'                   # sort by date
alias lm='la | less'

# Pacman aliases 
alias pac='/usr/bin/yaourt -S'				#defaultaction-install one or more packages
alias pacu='/usr/bin/yaourt -Syyuu'			#'[u]pdate'- upgrade all packages to their newest version
alias pacr='sudo /usr/bin/pacman -Rs'		#'[r]emove'- uninstall one or more packages
alias pacrf='sudo /usr/bin/pacman -Rscsn'	#[r]emove, [c]ascade, [n]nosave backup file, recur[s]ive MORE DANGEROUS!! 
alias pacs='/usr/bin/yaourt -Ss'			#'[s]earch'- search for a package using one or more keywords
alias paci='/usr/bin/yaourt -Si'			#'[i]nfo'- show information about a package
alias paclo='/usr/bin/yaourt -Qdt'			#'[l]ist [o]rphans'- list all packages which are orphaned
alias pacc='sudo /usr/bin/pacman -Scc'		#'[c]lean cache'- delete all not currently installed package files
alias pacl='/usr/bin/yaourt -Ql'			#'[l]ist files'- list all files installed by a given package
alias pacexpl='/usr/bin/yaourt -D --asexp'	#'mark as [expl]icit'- mark one or more packages as explicitly installed 
alias pacimpl='/usr/bin/yaourt -D --asdep'	#'mark as [impl]icit'- mark one or more packages as non explicitly installed
alias pacq='/usr/bin/pacman -Qs'			#List local packatges
alias pacro="/usr/bin/pacman -Qtdq > /dev/null && sudo /usr/bin/pacman -Rs \$(/usr/bin/pacman -Qtdq | sed -e ':a;N;$ba;s/\n/ /g')"
#'[r]emove [o]rphans' - recursively remove ALL orphaned packages
alias pacunlock="sudo rm /var/lib/pacman/db.lck"   # Delete the lock file /var/lib/pacman/db.lck
alias paclock="sudo touch /var/lib/pacman/db.lck"  # Create the lock file /var/lib/pacman/db.lck

# XDG Base Directory support
# https://wiki.archlinux.org/index.php/XDG_Base_Directory_support

alias abook="abook -C $XDG_CONFIG_HOME/abook/abookrc"
alias apvlv="apvlv -c $XDG_CONFIG_HOME/apvlvrc"
alias irssi="irssi --home=$XDG_CONFIG_HOME/irssi --config=$XDG_CONFIG_HOME/irssi/config"
alias msmtp="msmtp -C $XDG_CONFIG_HOME/msmtprc"
alias mutt="mutt -F $XDG_CONFIG_HOME/mutt/muttrc"
alias ncmpcpp="ncmpcpp --config '$XDG_CONFIG_HOME'/ncmpcpp/config"
