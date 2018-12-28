# FileName: $XDG_CONFIG_HOME/zsh/.zshrc
# vim:fenc=utf-8:nu:ai:si:et:ts=4:sw=4:ft=zsh:

# Sources 
#source /usr/share/oh-my-zsh/zshrc
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/nvm/init-nvm.sh
source $HOME/.opam/opam-init/init.zsh
source $ZDOTDIR/aliases.zsh
source $ZDOTDIR/functions.zsh


# Vim mode
bindkey -v

# Promp 
autoload -Uz promptinit
promptinit
prompt off

# Help
autoload -U run-help
autoload run-help-git
autoload run-help-svn
autoload run-help-svk
alias help=run-help

# History
HISTFILE=$ZDOTDIR/zsh_history
HISTSIZE=5000
SAVEHIST=10000 

# dirstack handling

DIRSTACKSIZE=${DIRSTACKSIZE:-50}
DIRSTACKFILE=${DIRSTACKFILE:-${ZDOTDIR}/zdirs}

# Settings for umask
if (( EUID == 0 )); then
    umask 002
else
    umask 022
fi

# Prompt theme extension ##
# Virtualenv support

function virtual_env_prompt () {
    REPLY=${VIRTUAL_ENV+(${VIRTUAL_ENV:t}) }
}
grml_theme_add_token  virtual-env -f virtual_env_prompt '%F{magenta}' '%f'
zstyle ':prompt:grml:left:setup' items rc virtual-env change-root user at host path vcs percent
#
## ZLE tweaks ##
#
## use the vi navigation keys (hjkl) besides cursor keys in menu completion
bindkey -M menuselect 'h' vi-backward-char        # left
bindkey -M menuselect 'k' vi-up-line-or-history   # up
bindkey -M menuselect 'l' vi-forward-char         # right
bindkey -M menuselect 'j' vi-down-line-or-history # bottom

bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# set command prediction from history, see 'man 1 zshcontrib'
zle -N predict-on         && \
zle -N predict-off        && \
bindkey "^X^Z" predict-on && \
bindkey "^Z" predict-off

# press ctrl-q to quote line:
mquote () {
      zle beginning-of-line
      zle forward-word
      # RBUFFER="'$RBUFFER'"
      RBUFFER=${(q)RBUFFER}
      zle end-of-line
}
zle -N mquote && bindkey '^q' mquote

# define word separators (for stuff like backward-word, forward-word, backward-kill-word,..)
WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>' # the default
#WORDCHARS=.
#WORDCHARS='*?_[]~=&;!#$%^(){}'
#WORDCHARS='${WORDCHARS:s@/@}'

#just type '...' to get '../..'
rationalise-dot() {
local MATCH
if [[ $LBUFFER =~ '(^|/| |	|'$'\n''|\||;|&)\.\.$' ]]; then
  LBUFFER+=/
  zle self-insert
  zle self-insert
else
  zle self-insert
fi
}
zle -N rationalise-dot
bindkey . rationalise-dot

# without this, typing a . aborts incremental history search
bindkey -M isearch . self-insert
bindkey '\eq' push-line-or-edit

# some popular options ##

# add `|' to output redirections in the history
setopt histallowclobber

# try to avoid the 'zsh: no matches found...'
setopt nonomatch

# warning if file exists ('cat /dev/null > ~/.zshrc')
setopt NO_clobber

# don't warn me about bg processes when exiting
setopt nocheckjobs

# Allow comments even in interactive shells
setopt interactivecomments

# compsys related snippets ##

# changed completer settings
zstyle ':completion:*' completer _complete _correct _approximate
zstyle ':completion:*' expand prefix suffix

# another different completer setting: expand shell aliases
zstyle ':completion:*' completer _expand_alias _complete _approximate

# to have more convenient account completion, specify your logins:
#my_accounts=(
# {grml,grml1}@foo.invalid
# grml-devel@bar.invalid
#)
#other_accounts=(
# {fred,root}@foo.invalid
# vera@bar.invalid
#)
#zstyle ':completion:*:my-accounts' users-hosts $my_accounts
#zstyle ':completion:*:other-accounts' users-hosts $other_accounts

# the default grml setup provides '..' as a completion. it does not provide
# '.' though. If you want that too, use the following line:
zstyle ':completion:*' special-dirs true

# miscellaneous code ##

# Use a default width of 80 for manpages for more convenient reading
export MANWIDTH=${MANWIDTH:-80}

# Set a search path for the cd builtin
cdpath=(.. ~ ~/workspace)

# log out? set timeout in seconds...
# ...and do not log out in some specific terminals:
#if [[ "${TERM}" == ([Exa]term*|rxvt|dtterm|screen*) ]] ; then
#    unset TMOUT
#else
#    TMOUT=1800
#fi

# associate types and extensions (be aware with perl scripts and anwanted behaviour!)
check_com zsh-mime-setup || { autoload zsh-mime-setup && zsh-mime-setup }
alias -s pl='perl -S'

# ctrl-s will no longer freeze the terminal.
stty erase "^?"

# X TERM
case $TERM in 
    st*|xterm*)
        function zle-line-init () { echoti smkx }
        function zle-line-finish () { echoti rmkx }
        zle -N zle-line-init
        zle -N zle-line-finish
        precmd () { print -Pn "\e]0;$(pwd | sed 's/\/home\/'`whoami`'/~/')\a" }
esac

# npm command completion script
if type complete &>/dev/null; then
  _npm_completion () {
    local words cword
    if type _get_comp_words_by_ref &>/dev/null; then
      _get_comp_words_by_ref -n = -n @ -w words -i cword
    else
      cword="$COMP_CWORD"
      words=("${COMP_WORDS[@]}")
    fi

    local si="$IFS"
    IFS=$'\n' COMPREPLY=($(COMP_CWORD="$cword" \
                           COMP_LINE="$COMP_LINE" \
                           COMP_POINT="$COMP_POINT" \
                           npm completion -- "${words[@]}" \
                           2>/dev/null)) || return $?
    IFS="$si"
  }
  complete -o default -F _npm_completion npm
elif type compdef &>/dev/null; then
  _npm_completion() {
    local si=$IFS
    compadd -- $(COMP_CWORD=$((CURRENT-1)) \
                 COMP_LINE=$BUFFER \
                 COMP_POINT=0 \
                 npm completion -- "${words[@]}" \
                 2>/dev/null)
    IFS=$si
  }
  compdef _npm_completion npm
elif type compctl &>/dev/null; then
  _npm_completion () {
    local cword line point words si
    read -Ac words
    read -cn cword
    let cword-=1
    read -l line
    read -ln point
    si="$IFS"
    IFS=$'\n' reply=($(COMP_CWORD="$cword" \
                       COMP_LINE="$line" \
                       COMP_POINT="$point" \
                       npm completion -- "${words[@]}" \
                       2>/dev/null)) || return $?
    IFS="$si"
  }
  compctl -K _npm_completion npm
fi
###-end-npm-completion-###

#compdef rustup

autoload -U is-at-least

_rustup() {
    typeset -A opt_args
    typeset -a _arguments_options
    local ret=1

    if is-at-least 5.2; then
        _arguments_options=(-s -S -C)
    else
        _arguments_options=(-s -C)
    fi

    local context curcontext="$curcontext" state line
    _arguments "${_arguments_options[@]}" \
'-v[Enable verbose output]' \
'--verbose[Enable verbose output]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
":: :_rustup_commands" \
"*::: :->rustup" \
&& ret=0
    case $state in
    (rustup)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:rustup-command-$line[1]:"
        case $line[1] in
            (show)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(install)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':toolchain -- Toolchain name, such as 'stable', 'nightly', or '1.8.0'. For more information see `rustup help toolchain`:_files' \
&& ret=0
;;
(uninstall)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':toolchain -- Toolchain name, such as 'stable', 'nightly', or '1.8.0'. For more information see `rustup help toolchain`:_files' \
&& ret=0
;;
(update)
_arguments "${_arguments_options[@]}" \
'--no-self-update[Don'\''t perform self update when running the `rustup` command]' \
'--force[Force an update, even if some components are missing]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
'::toolchain -- Toolchain name, such as 'stable', 'nightly', or '1.8.0'. For more information see `rustup help toolchain`:_files' \
&& ret=0
;;
(default)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':toolchain -- Toolchain name, such as 'stable', 'nightly', or '1.8.0'. For more information see `rustup help toolchain`:_files' \
&& ret=0
;;
(toolchain)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
":: :_rustup__toolchain_commands" \
"*::: :->toolchain" \
&& ret=0
case $state in
    (toolchain)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:rustup-toolchain-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(update)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':toolchain -- Toolchain name, such as 'stable', 'nightly', or '1.8.0'. For more information see `rustup help toolchain`:_files' \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':toolchain -- Toolchain name, such as 'stable', 'nightly', or '1.8.0'. For more information see `rustup help toolchain`:_files' \
&& ret=0
;;
(install)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':toolchain -- Toolchain name, such as 'stable', 'nightly', or '1.8.0'. For more information see `rustup help toolchain`:_files' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':toolchain -- Toolchain name, such as 'stable', 'nightly', or '1.8.0'. For more information see `rustup help toolchain`:_files' \
&& ret=0
;;
(uninstall)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':toolchain -- Toolchain name, such as 'stable', 'nightly', or '1.8.0'. For more information see `rustup help toolchain`:_files' \
&& ret=0
;;
(link)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':toolchain -- Toolchain name, such as 'stable', 'nightly', or '1.8.0'. For more information see `rustup help toolchain`:_files' \
':path:_files' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
        esac
    ;;
esac
;;
(target)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
":: :_rustup__target_commands" \
"*::: :->target" \
&& ret=0
case $state in
    (target)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:rustup-target-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
'--toolchain=[Toolchain name, such as '\''stable'\'', '\''nightly'\'', or '\''1.8.0'\''. For more information see `rustup help toolchain`]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(install)
_arguments "${_arguments_options[@]}" \
'--toolchain=[Toolchain name, such as '\''stable'\'', '\''nightly'\'', or '\''1.8.0'\''. For more information see `rustup help toolchain`]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':target:_files' \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" \
'--toolchain=[Toolchain name, such as '\''stable'\'', '\''nightly'\'', or '\''1.8.0'\''. For more information see `rustup help toolchain`]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':target:_files' \
&& ret=0
;;
(uninstall)
_arguments "${_arguments_options[@]}" \
'--toolchain=[Toolchain name, such as '\''stable'\'', '\''nightly'\'', or '\''1.8.0'\''. For more information see `rustup help toolchain`]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':target:_files' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" \
'--toolchain=[Toolchain name, such as '\''stable'\'', '\''nightly'\'', or '\''1.8.0'\''. For more information see `rustup help toolchain`]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':target:_files' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
        esac
    ;;
esac
;;
(component)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
":: :_rustup__component_commands" \
"*::: :->component" \
&& ret=0
case $state in
    (component)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:rustup-component-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
'--toolchain=[Toolchain name, such as '\''stable'\'', '\''nightly'\'', or '\''1.8.0'\''. For more information see `rustup help toolchain`]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" \
'--toolchain=[Toolchain name, such as '\''stable'\'', '\''nightly'\'', or '\''1.8.0'\''. For more information see `rustup help toolchain`]' \
'--target=[]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':component:_files' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" \
'--toolchain=[Toolchain name, such as '\''stable'\'', '\''nightly'\'', or '\''1.8.0'\''. For more information see `rustup help toolchain`]' \
'--target=[]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':component:_files' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
        esac
    ;;
esac
;;
(override)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
":: :_rustup__override_commands" \
"*::: :->override" \
&& ret=0
case $state in
    (override)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:rustup-override-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':toolchain -- Toolchain name, such as 'stable', 'nightly', or '1.8.0'. For more information see `rustup help toolchain`:_files' \
&& ret=0
;;
(set)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':toolchain -- Toolchain name, such as 'stable', 'nightly', or '1.8.0'. For more information see `rustup help toolchain`:_files' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" \
'--path=[Path to the directory]' \
'--nonexistent[Remove override toolchain for all nonexistent directories]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(unset)
_arguments "${_arguments_options[@]}" \
'--path=[Path to the directory]' \
'--nonexistent[Remove override toolchain for all nonexistent directories]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
        esac
    ;;
esac
;;
(run)
_arguments "${_arguments_options[@]}" \
'--install[Install the requested toolchain if needed]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':toolchain -- Toolchain name, such as 'stable', 'nightly', or '1.8.0'. For more information see `rustup help toolchain`:_files' \
':command:_files' \
&& ret=0
;;
(which)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':command:_files' \
&& ret=0
;;
(docs)
_arguments "${_arguments_options[@]}" \
'--book[The Rust Programming Language book]' \
'--std[Standard library API documentation]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(doc)
_arguments "${_arguments_options[@]}" \
'--book[The Rust Programming Language book]' \
'--std[Standard library API documentation]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(man)
_arguments "${_arguments_options[@]}" \
'--toolchain=[Toolchain name, such as '\''stable'\'', '\''nightly'\'', or '\''1.8.0'\''. For more information see `rustup help toolchain`]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':command:_files' \
&& ret=0
;;
(self)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
":: :_rustup__self_commands" \
"*::: :->self" \
&& ret=0
case $state in
    (self)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:rustup-self-command-$line[1]:"
        case $line[1] in
            (update)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(uninstall)
_arguments "${_arguments_options[@]}" \
'-y[]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(upgrade-data)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
        esac
    ;;
esac
;;
(telemetry)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
":: :_rustup__telemetry_commands" \
"*::: :->telemetry" \
&& ret=0
case $state in
    (telemetry)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:rustup-telemetry-command-$line[1]:"
        case $line[1] in
            (enable)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(disable)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(analyze)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
        esac
    ;;
esac
;;
(set)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
":: :_rustup__set_commands" \
"*::: :->set" \
&& ret=0
case $state in
    (set)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:rustup-set-command-$line[1]:"
        case $line[1] in
            (default-host)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':host_triple:_files' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
        esac
    ;;
esac
;;
(completions)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
'::shell:(zsh bash fish powershell)' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
        esac
    ;;
esac
}

(( $+functions[_rustup_commands] )) ||
_rustup_commands() {
    local commands; commands=(
        "show:Show the active and installed toolchains" \
"install:Update Rust toolchains" \
"uninstall:Uninstall Rust toolchains" \
"update:Update Rust toolchains and rustup" \
"default:Set the default toolchain" \
"toolchain:Modify or query the installed toolchains" \
"target:Modify a toolchain's supported targets" \
"component:Modify a toolchain's installed components" \
"override:Modify directory toolchain overrides" \
"run:Run a command with an environment configured for a given toolchain" \
"which:Display which binary will be run for a given command" \
"doc:Open the documentation for the current toolchain" \
"man:View the man page for a given command" \
"self:Modify the rustup installation" \
"telemetry:rustup telemetry commands" \
"set:Alter rustup settings" \
"completions:Generate completion scripts for your shell" \
"help:Prints this message or the help of the given subcommand(s)" \
    )
    _describe -t commands 'rustup commands' commands "$@"
}
(( $+functions[_rustup__add_commands] )) ||
_rustup__add_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup add commands' commands "$@"
}
(( $+functions[_rustup__component__add_commands] )) ||
_rustup__component__add_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup component add commands' commands "$@"
}
(( $+functions[_rustup__override__add_commands] )) ||
_rustup__override__add_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup override add commands' commands "$@"
}
(( $+functions[_rustup__target__add_commands] )) ||
_rustup__target__add_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup target add commands' commands "$@"
}
(( $+functions[_rustup__toolchain__add_commands] )) ||
_rustup__toolchain__add_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup toolchain add commands' commands "$@"
}
(( $+functions[_rustup__telemetry__analyze_commands] )) ||
_rustup__telemetry__analyze_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup telemetry analyze commands' commands "$@"
}
(( $+functions[_rustup__completions_commands] )) ||
_rustup__completions_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup completions commands' commands "$@"
}
(( $+functions[_rustup__component_commands] )) ||
_rustup__component_commands() {
    local commands; commands=(
        "list:List installed and available components" \
"add:Add a component to a Rust toolchain" \
"remove:Remove a component from a Rust toolchain" \
"help:Prints this message or the help of the given subcommand(s)" \
    )
    _describe -t commands 'rustup component commands' commands "$@"
}
(( $+functions[_rustup__default_commands] )) ||
_rustup__default_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup default commands' commands "$@"
}
(( $+functions[_rustup__set__default-host_commands] )) ||
_rustup__set__default-host_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup set default-host commands' commands "$@"
}
(( $+functions[_rustup__telemetry__disable_commands] )) ||
_rustup__telemetry__disable_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup telemetry disable commands' commands "$@"
}
(( $+functions[_rustup__doc_commands] )) ||
_rustup__doc_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup doc commands' commands "$@"
}
(( $+functions[_docs_commands] )) ||
_docs_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'docs commands' commands "$@"
}
(( $+functions[_rustup__docs_commands] )) ||
_rustup__docs_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup docs commands' commands "$@"
}
(( $+functions[_rustup__telemetry__enable_commands] )) ||
_rustup__telemetry__enable_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup telemetry enable commands' commands "$@"
}
(( $+functions[_rustup__component__help_commands] )) ||
_rustup__component__help_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup component help commands' commands "$@"
}
(( $+functions[_rustup__help_commands] )) ||
_rustup__help_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup help commands' commands "$@"
}
(( $+functions[_rustup__override__help_commands] )) ||
_rustup__override__help_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup override help commands' commands "$@"
}
(( $+functions[_rustup__self__help_commands] )) ||
_rustup__self__help_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup self help commands' commands "$@"
}
(( $+functions[_rustup__set__help_commands] )) ||
_rustup__set__help_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup set help commands' commands "$@"
}
(( $+functions[_rustup__target__help_commands] )) ||
_rustup__target__help_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup target help commands' commands "$@"
}
(( $+functions[_rustup__telemetry__help_commands] )) ||
_rustup__telemetry__help_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup telemetry help commands' commands "$@"
}
(( $+functions[_rustup__toolchain__help_commands] )) ||
_rustup__toolchain__help_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup toolchain help commands' commands "$@"
}
(( $+functions[_rustup__install_commands] )) ||
_rustup__install_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup install commands' commands "$@"
}
(( $+functions[_rustup__target__install_commands] )) ||
_rustup__target__install_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup target install commands' commands "$@"
}
(( $+functions[_rustup__toolchain__install_commands] )) ||
_rustup__toolchain__install_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup toolchain install commands' commands "$@"
}
(( $+functions[_rustup__toolchain__link_commands] )) ||
_rustup__toolchain__link_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup toolchain link commands' commands "$@"
}
(( $+functions[_rustup__component__list_commands] )) ||
_rustup__component__list_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup component list commands' commands "$@"
}
(( $+functions[_rustup__override__list_commands] )) ||
_rustup__override__list_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup override list commands' commands "$@"
}
(( $+functions[_rustup__target__list_commands] )) ||
_rustup__target__list_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup target list commands' commands "$@"
}
(( $+functions[_rustup__toolchain__list_commands] )) ||
_rustup__toolchain__list_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup toolchain list commands' commands "$@"
}
(( $+functions[_rustup__man_commands] )) ||
_rustup__man_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup man commands' commands "$@"
}
(( $+functions[_rustup__override_commands] )) ||
_rustup__override_commands() {
    local commands; commands=(
        "list:List directory toolchain overrides" \
"set:Set the override toolchain for a directory" \
"unset:Remove the override toolchain for a directory" \
"help:Prints this message or the help of the given subcommand(s)" \
    )
    _describe -t commands 'rustup override commands' commands "$@"
}
(( $+functions[_rustup__component__remove_commands] )) ||
_rustup__component__remove_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup component remove commands' commands "$@"
}
(( $+functions[_rustup__override__remove_commands] )) ||
_rustup__override__remove_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup override remove commands' commands "$@"
}
(( $+functions[_rustup__remove_commands] )) ||
_rustup__remove_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup remove commands' commands "$@"
}
(( $+functions[_rustup__target__remove_commands] )) ||
_rustup__target__remove_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup target remove commands' commands "$@"
}
(( $+functions[_rustup__toolchain__remove_commands] )) ||
_rustup__toolchain__remove_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup toolchain remove commands' commands "$@"
}
(( $+functions[_rustup__run_commands] )) ||
_rustup__run_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup run commands' commands "$@"
}
(( $+functions[_rustup__self_commands] )) ||
_rustup__self_commands() {
    local commands; commands=(
        "update:Download and install updates to rustup" \
"uninstall:Uninstall rustup." \
"upgrade-data:Upgrade the internal data format." \
"help:Prints this message or the help of the given subcommand(s)" \
    )
    _describe -t commands 'rustup self commands' commands "$@"
}
(( $+functions[_rustup__override__set_commands] )) ||
_rustup__override__set_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup override set commands' commands "$@"
}
(( $+functions[_rustup__set_commands] )) ||
_rustup__set_commands() {
    local commands; commands=(
        "default-host:The triple used to identify toolchains when not specified" \
"help:Prints this message or the help of the given subcommand(s)" \
    )
    _describe -t commands 'rustup set commands' commands "$@"
}
(( $+functions[_rustup__show_commands] )) ||
_rustup__show_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup show commands' commands "$@"
}
(( $+functions[_rustup__target_commands] )) ||
_rustup__target_commands() {
    local commands; commands=(
        "list:List installed and available targets" \
"add:Add a target to a Rust toolchain" \
"remove:Remove a target from a Rust toolchain" \
"help:Prints this message or the help of the given subcommand(s)" \
    )
    _describe -t commands 'rustup target commands' commands "$@"
}
(( $+functions[_rustup__telemetry_commands] )) ||
_rustup__telemetry_commands() {
    local commands; commands=(
        "enable:Enable rustup telemetry" \
"disable:Disable rustup telemetry" \
"analyze:Analyze stored telemetry" \
"help:Prints this message or the help of the given subcommand(s)" \
    )
    _describe -t commands 'rustup telemetry commands' commands "$@"
}
(( $+functions[_rustup__toolchain_commands] )) ||
_rustup__toolchain_commands() {
    local commands; commands=(
        "list:List installed toolchains" \
"install:Install or update a given toolchain" \
"uninstall:Uninstall a toolchain" \
"link:Create a custom toolchain by symlinking to a directory" \
"help:Prints this message or the help of the given subcommand(s)" \
    )
    _describe -t commands 'rustup toolchain commands' commands "$@"
}
(( $+functions[_rustup__self__uninstall_commands] )) ||
_rustup__self__uninstall_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup self uninstall commands' commands "$@"
}
(( $+functions[_rustup__target__uninstall_commands] )) ||
_rustup__target__uninstall_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup target uninstall commands' commands "$@"
}
(( $+functions[_rustup__toolchain__uninstall_commands] )) ||
_rustup__toolchain__uninstall_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup toolchain uninstall commands' commands "$@"
}
(( $+functions[_rustup__uninstall_commands] )) ||
_rustup__uninstall_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup uninstall commands' commands "$@"
}
(( $+functions[_rustup__override__unset_commands] )) ||
_rustup__override__unset_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup override unset commands' commands "$@"
}
(( $+functions[_rustup__self__update_commands] )) ||
_rustup__self__update_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup self update commands' commands "$@"
}
(( $+functions[_rustup__toolchain__update_commands] )) ||
_rustup__toolchain__update_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup toolchain update commands' commands "$@"
}
(( $+functions[_rustup__update_commands] )) ||
_rustup__update_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup update commands' commands "$@"
}
(( $+functions[_rustup__self__upgrade-data_commands] )) ||
_rustup__self__upgrade-data_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup self upgrade-data commands' commands "$@"
}
(( $+functions[_rustup__which_commands] )) ||
_rustup__which_commands() {
    local commands; commands=(
        
    )
    _describe -t commands 'rustup which commands' commands "$@"
}

_rustup "$@"
