source /usr/share/fonts/awesome-terminal-fonts/fontawesome-regular.sh
typeset -g POWERLEVEL9K_MODE=awesome-fontconfig
typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true

typeset -g POWERLEVEL9K_USER_{DEFAULT,SUDO,ROOT}_BACKGROUND='235'
typeset -g POWERLEVEL9K_USER_DEFAULT_FOREGROUND='245'
typeset -g POWERLEVEL9K_USER_{SUDO,ROOT}_FOREGROUND='009'

typeset -g POWERLEVEL9K_HOST_{LOCAL,REMOTE}_BACKGROUND='240'
typeset -g POWERLEVEL9K_HOST_LOCAL_FOREGROUND='232'
typeset -g POWERLEVEL9K_HOST_REMOTE_FOREGROUND='229'

typeset -g POWERLEVEL9K_DIR_{HOME,HOME_SUBFOLDER}_BACKGROUND='017'
typeset -g POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='052'
typeset -g POWERLEVEL9K_DIR_ETC_BACKGROUND='089'
typeset -g POWERLEVEL9K_DIR_{HOME,HOME_SUBFOLDER,DEFAULT,ETC}_FOREGROUND='147'
typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_first_and_last

typeset -g POWERLEVEL9K_CUSTOM_VCSH=zsh_vcsh
typeset -g POWERLEVEL9K_CUSTOM_VCSH_BACKGROUND='202'
typeset -g POWERLEVEL9K_CUSTOM_VCSH_FOREGROUND='234'
zsh_vcsh () {
	echo -n ${VCSH_REPO_NAME}
}

typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND='127'
typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED}_BACKGROUND='053'
typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='220'
typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED}_FOREGROUND='218'
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='232'
typeset -g POWERLEVEL9K_VCS_SHOW_SUBMODULE_DIRTY=true

typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND='235'
typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND='245'
typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND='124'
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND='224'

typeset -g POWERLEVEL9K_HISTORY_BACKGROUND='240'
typeset -g POWERLEVEL9K_HISTORY_FOREGROUND='232'

typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND='235'
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='245'
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=1

typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(root_indicator user host dir custom_vcsh vcs)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status history background_jobs command_execution_time)

typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%B%F{red}❯%F{yellow}❯%F{green}❯%f%b "

# {{{ Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi
# }}}

# {{{ Set additional options I like beyond the zsh and prezto defaults
setopt autocontinue
setopt dvorak
setopt histreduceblanks
setopt magicequalsubst
setopt markdirs
setopt menucomplete
setopt numericglobsort
setopt shnullcmd
setopt globcomplete
unsetopt autoremoveslash
unsetopt beep
unsetopt histbeep
unsetopt listbeep
unsetopt nomatch
unsetopt histverify
# }}}

# {{{ OS specific options for later re-use
case $(uname -s) in
	Darwin)
		lscolor='-G'
		;;
	Linux)
		lscolor='--color=always'
		;;
esac
# }}}

# Add extra bindings for modules loaded by zprezto
# (currently conflicting with tmux/vim split navigation, using cmd mode anyway)
#bindkey -M viins "^K" history-substring-search-up
#bindkey -M viins "^J" history-substring-search-down

# {{{ These doesn't get set right on some of my systems
export HOSTNAME=${HOSTNAME:=${$(hostname)%%\.*}}
umask 022
# }}}

# {{{ Enable editing of current command in editor
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^E" edit-command-line
# }}}

# bindkey "^ " autosuggest-accept
# bindkey "^$key_info[Enter]" autosuggest-accept

# {{{ Extra bindings
bindkey "^F" transpose-words

# http://unix.stackexchange.com/questions/10825/remember-a-half-typed-command-while-i-check-something/11982#11982
fancy-ctrl-z () {
  emulate -LR zsh
  if [[ $#BUFFER -eq 0 ]]; then
    bg
    zle redisplay
  else
    zle push-input
  fi
}

zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z
# }}}

# {{{ Default argument aliases
alias mkiso='mkisofs -J -r -joliet-long -o'
alias poldek="poldek --cachedir=$HOME/tmp/poldek-cache-$USER-$HOSTNAME"
alias grep="grep --no-messages --exclude-dir=.git --exclude=*~ --exclude=*.swp"
alias rdesktop="rdesktop -k en-dv"
# }}}

# {{{ Personal lazy aliases
alias ddstatus='sudo pkill -USR1 -x dd'
alias sc='sudo -E systemctl'
alias scu='systemctl --user'
alias jc='journalctl'
alias jcu='journalctl --user'
alias se='sudoedit'
alias h="vcsh"
alias lv="ls -al $lscolor|less"
alias md2pdf="pandoc --latex-engine=xelatex -t latex"
alias gmv="noglob zmv -W"
alias add="paste -sd+ - | bc"

# Note these build on both zprezto's git alias's and my own git config
alias gaf="git af"
alias gap="git ap"
alias gau="git au"
alias gca="git ca"
alias gcb="git cb"
alias gce="git ce"
alias gce="git ce"
alias gcp="git cp"
alias gd="git d"
alias gdc="git dc"
alias gdsc="git dsc"
alias gds="git ds"
alias gdw="git dw"
alias gdsw="git dsw"
alias gg="git g"
alias gs="git s"
alias gsc="git sc"
alias gsw="git sw"

if [[ $TERM_PROGRAM == "iTerm.app" ]]; then
	alias v="mvim --remote-tab-silent"
#elif [[ -n "$DESKTOP_SESSION" ]]; then
	#alias v="gvim -p --remote-tab-silent"
#elif [[ -n "$VISUAL" ]]; then
	#alias v=$VISUAL
else
	alias v='f -e nvim'
fi
# }}}

# {{{ Convenience functions
auth () {
	eval $(~/bin/que-auth.zsh)
}
fit() {
	cut -b1-$COLUMNS $@
}
lineTrim () {
	bottom=$2
	let top=$bottom-$1+1
	head -n $bottom | tail -n $top
}

sourceifexists () {
	[ -f "$1" ] && source "$1"
}
vcsh() {
	case $1; in
		list-untracked)
			command ls | grep -vxf <(vcsh list-tracked)
			;;
		*)
			command vcsh "$@"
			;;
	esac
}

# View the memory usage status of profile-sync-daemon and anything-sync-daemon
sds () {
	{ asd preview ; psd preview } | grep -E '(manage|size|psname):'
}
serve () {
	: ${1:=./}
	srv=/srv/http
	test -d $srv || return 1
	mount | grep -q $srv && sudo umount $srv
	sudo mount --bind $1 $srv
	sudo systemctl restart httpd.service
}
# }}}

function drivetemps () {
	for drive in /dev/sd[a-z]; do sudo smartctl --all $drive | grep Temperature_Celsius; done
}

# {{{ Path fixes (and system specific hacks)

function addtopath () {
	[ -d $1 ] && path=($path $1)
}

addtopath /usr/texbin
addtopath ~/projects/android/sdk/tools
addtopath /usr/local/apache-ant-1.6.5/bin
addtopath /opt/android-sdk/platform-tools
addtopath /opt/android-sdk/tools
addtopath $(python -c "import site; print(site.getsitepackages()[0]+'/bin')")
addtopath ~/projects/tprk/aletler/bin
addtopath ~/projects/viachristus/avadanlik/bin
addtopath ~/.cabal/bin
addtopath ~/node_modules/.bin
addtopath ~/.local/bin

if [ -d ~/.ec2/ec2-api-tools ]; then
	export ec2_home=~/.ec2/ec2-api-tools
	export libdir=$ec2_home/lib
	addtopath $ec2_home/bin
fi

# PHP Composer puts various per-user things here (e.g. drush)
addtopath ~/.composer/vendor/bin/

# }}}

# {{{ Include encrypted stuff in another repo
sourceifexists ~/.zshrc-private

case $HOSTNAME in
camelion|iguana|basilisk) local hostcolor=yellow ;;
	ns*|*server|mysql|sub|mail|*spam) local hostcolor=red ;;
	goose|gander) local hostcolor=blue;;
	leylek|lemur|pars|jaguar|karabatak|shrimp|lobster|oyster|hare) local hostcolor=cyan ;;
	*) local hostcolor=magenta ;;
esac
# }}}

# {{{ Include FZF magic
export FZF_DEFAULT_COMMAND='(git ls-all-trees || find . -path "*/\.*" -prune -o -type f -print -o -type l -print | sed s/^..//) 2> /dev/null'
alias fzf='fzf-tmux'
source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh

# Load special tmux magic functions if present
test -f ~/.tmux.zsh && source  ~/.tmux.zsh

fkill() {
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]
  then
    kill -${1:-9} $pid
  fi
}
fbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}
fco() {
  local commits commit
  commits=$(git log --pretty=oneline --abbrev-commit --reverse) &&
  commit=$(echo "$commits" | fzf --tac +s +m -e) &&
  git checkout $(echo "$commit" | sed "s/ .*//")
}
fshow() {
  local out sha q
  while out=$(
      git log --decorate=short --graph --oneline --color=always |
      fzf --ansi --multi --no-sort --reverse --query="$q" --print-query); do
    q=$(head -1 <<< "$out")
    while read sha; do
      [ -n "$sha" ] && git show --color=always $sha | less -R
    done < <(sed '1d;s/^[^a-z0-9]*//;/^$/d' <<< "$out" | awk '{print $1}')
  done
}
# }}}

eval "$(fasd --init auto)"
bindkey '^X^A' fasd-complete
bindkey '^X^F' fasd-complete-f
bindkey '^X^D' fasd-complete-d

# Setup completion for remake
compdef _make remake
alias make='remake'

# Sometimes GPG can't find it's own nose
export GPG_TTY=$(tty)

# added by travis gem
[ -f /home/caleb/.travis/travis.sh ] && source /home/caleb/.travis/travis.sh

# Skip old configs for now
return

# {{{ -- Old unrefactored bits

pcd () {
	d1="$PICTUREDIR/$1"
	d2="$PICTUREDIR/`echo $1 | perl -pne 's/^\d* //g'`"
	if [ -d "$d1" ]; then
		cd "$d1"
	else
		if [ -d "$d2" ]; then
			cd "$d2"
		else
			[ -n "$1" ] && n=$1 || n=1
			/bin/ls $PICTUREDIR |
				tail -n $n |
				head -n 1 |
				read dir
			cd $PICTUREDIR/$dir
		fi
	fi
}

thumbs () {
	pwd | read dir
	x=0
	y=0
	/bin/ls |
		pcregrep -i '(jpg|png|gif)$' |
		while read img; do
			if [ $x -gt 1280 ]; then
				x=0
				let y=$y+90
			fi
			if [ $y -gt 1000 ]; then
				echo ERROR: out of screen space!
				continue
			fi
			if [ "$1" = "full" ]; then
				xv "$img" -bw 120 -geometry x90+$x+$y &
			else
				if [ ! -f "$THUMBDIR/$img" ]; then
					convert -size 120 "$img" -resize 120 "$THUMBDIR/$img"
					xv "$THUMBDIR/$img" -geometry x90+$x+$y &
				else 
					xv "$THUMBDIR/$img" -geometry x90+$x+$y &
				fi
			fi
			let x=$x+120
		done
}

function zle-keymap-select {
	vim_mode="${${KEYMAP/vicmd/${vim_cmd_mode}}/(main|viins)/${vim_ins_mode}}"
	zle reset-prompt
}
zle -N zle-keymap-select

function zle-line-finish {
	vim_mode=$vim_ins_mode
}
zle -N zle-line-finish

PICTUREDIR=/pictures
THUMBDIR=/pictures/thumbs

## COMPLETION ##
zsh_complete_tmux_list () {
	reply=($(tmux ls -F '#S' 2>-))
}
zsh_get_host_list () {
	reply=(`dig axfr ouraynet.com @ns1.ouraynet.com|
		pcregrep '^[a-z]\w*\.ouraynet\.com'|
		cut -d\. -f1`)
}
zsh_get_user_list () {
	reply=($(cut -d: -f1 /etc/passwd))
}
zsh_get_picture_dirs () {
	IFS='^'
	reply=(`/bin/ls $PICTUREDIR | wc -l | read count
		/bin/ls $PICTUREDIR |
		while read line; do
			echo $count | perl -pne 's/^(\d)$/0\\1/' | read count
			echo -n $count $line^
			let count=$count-1
		done`)
}
compctl -K zsh_get_picture_dirs pcd
compctl -K zsh_complete_tmux_list tmux t tx
compctl -g '~/.teamocil/*(:t:r)' teamocil

compctl -g "*(-/) .*(-/)" cd rmdir
compctl -u passwd be
compctl -g "*.rpm" + -g "*(-/) .*(-/)" rpm2cpio rpm
compctl -g "*.tgz *.tar.gz *.rpm" + -g "*(/) .*(/)" rpmbuild
compctl -g "*.deb *.rpm *.tgz" + -g "*(-/) .*(-/)" alien
compctl -g "*.exe *.Exe *.EXE" + -g "*(-/) .*(-/)" wine

trim() {
	echo $1
}

# Typing convenience aliases
alias l="ls -al $lscolor"
alias ls="ls -BF $lscolor"
alias la="ls -a $lscolor"
alias br='sudo -s'
alias sort="sort -h"
alias dig="dig +noall +answer"

accept-line() { prev_mode=$KEYMAP; zle .accept-line }
zle-line-init() { zle -K ${prev_mode:-viins} }
zle -N accept-line
zle -N zle-line-init

export KEYTIMEOUT=1

# }}}

# vim: foldmethod=marker
