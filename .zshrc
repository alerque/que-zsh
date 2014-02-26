export HOSTNAME=${HOSTNAME:=$(hostname -s)}

autoload -Uz colors && colors

autoload -Uz incremental-complete-word
zle -N incremental-complete-word

autoload -Uz compinit && compinit
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
zstyle ':completion:*' menu select

autoload -z edit-command-line
zle -N edit-command-line

# Enable the vcs_info module so we can make PROMPT VCS aware
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn

auth () {
	which keychain > /dev/null 2>&1 || return
	eval $(keychain --eval -Q --quiet ~/.ssh/id_rsa ~/.ssh/github)
}

lineTrim () {
	bottom=$2
	let top=$bottom-$1+1
	head -n $bottom | tail -n $top
}

sourceifexists () {
	[ -f "$1" ] && source "$1"
}

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
alias kk='killall xv'
alias ddstatus='sudo pkill -USR1 -x dd'
alias sc='sudo systemctl'
compdef sc='systemctl'
alias se='sudoedit'
compdef se='sudoedit'
command -v yaourt && {
	alias ya='yaourt --noconfirm'
	compdef ya='pacman'
}

unset MAIL MAILCHECK MAILPATH
HISTSIZE=50000
SAVEHIST=50000
EDITOR=vim
VISUAL=vim
PAGER='less -r'

[ -d ~/projects/android/sdk/tools ] && path=($path ~/projects/android/sdk/tools)
[ -d /usr/local/apache-ant-1.6.5 ] && path=($path /usr/local/apache-ant-1.6.5/bin)
[ -d /opt/android-sdk/platform-tools ] && path=($path /opt/android-sdk/platform-tools)
[ -d /opt/android-sdk/tools ] && path=($path /opt/android-sdk/tools)

preexec() {
	# Give tmux some info on what is running in the shell before we go off and do it
	[ -n "$TMUX_PANE" ] && print -Pn "k`echo $2|perl -pne 's!\s.*/! !g'|cut -c1-16`\\"
}

precmd () {
	vcs_info
	if [ -n "$TMUX_PANE" ]; then
		# Let tmux know we're back at a prompt
		print -Pn "k \\"
		#print -Pn ']0;%m:%~'
	fi
}

vim_ins_mode="%F{green}"
vim_cmd_mode="%F{white}"
vim_mode=$vim_ins_mode

function zle-keymap-select {
	vim_mode="${${KEYMAP/vicmd/${vim_cmd_mode}}/(main|viins)/${vim_ins_mode}}"
	zle reset-prompt
}
zle -N zle-keymap-select

function zle-line-finish {
	vim_mode=$vim_ins_mode
}
zle -N zle-line-finish

#RPROMPT='%F{black}%* ${vim_mode}'


zstyle ':vcs_info:*' stagedstr 'M' 
zstyle ':vcs_info:*' unstagedstr 'M' 
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' formats '%F{5}%s{%F{green}%b%F{5}} %F{yellow}%a%F{green}%c%F{red}%u%F{red}%m%f'
zstyle ':vcs_info:*' actionformats '%F{5}%s{%F{green}%b%F{5}}-%a %F{yellow}%a%F{green}%c%F{red}%u%F{red}%m%f'
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
+vi-git-untracked() {
  if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
    git status --porcelain | grep '??' &> /dev/null ; then
    hook_com[unstaged]+='%F{1}?%f'
  fi  
}

local lastexitcode='%(?,%F{green}✓,%F{red}✗)%f'
PROMPT='$lastexitcode %F{5}[%(0#,%F{red}%n,%F{blue}%n)%F{5}@%F{$hostcolor}%m%F{5}] %F{green}%~ %F{yellow}$VCSH_REPO_NAME ${vcs_info_msg_0_} %F{black}(%!)
${vim_mode}%# %f'
RPROMPT='%F{black}%*'
PICTUREDIR=/pictures
THUMBDIR=/pictures/thumbs

export HISTSIZE HISTFILE SAVEHIST PROMPT RPROMPT EDITOR VISUAL PAGER

umask 022

#setopt NOTIFY
#setopt HIST_IGNORE_SPACE
#setopt HIST_IGNORE_DUPS
#setopt interactivecomment

setopt autocd
setopt completealiases
setopt extendedglob
unsetopt nomatch
setopt histignoredups
setopt multios
setopt prompt_subst
setopt pushdignoredups

#no console beep
setopt nobeep
echo -en "[11;0]"

bindkey -v
bindkey "^K" history-search-backward
bindkey "^J" history-search-forward
bindkey "^F" history-incremental-search-backward
bindkey "^R" transpose-words
bindkey "^E" edit-command-line

kill-last-word () {
	zle backward-word
	zle kill-word
}
zle -N kill-last-word
bindkey "^L" kill-last-word

# Key binding method copied from https://wiki.archlinux.org/index.php/Zsh#Key_bindings
typeset -A key

key[Home]=${terminfo[khome]}

key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

[[ -n "${key[Home]}"    ]]  && bindkey  "${key[Home]}"    beginning-of-line
[[ -n "${key[End]}"     ]]  && bindkey  "${key[End]}"     end-of-line
[[ -n "${key[Insert]}"  ]]  && bindkey  "${key[Insert]}"  overwrite-mode
[[ -n "${key[Delete]}"  ]]  && bindkey  "${key[Delete]}"  delete-char
[[ -n "${key[Up]}"      ]]  && bindkey  "${key[Up]}"      up-line-or-history
[[ -n "${key[Down]}"    ]]  && bindkey  "${key[Down]}"    down-line-or-history
[[ -n "${key[Left]}"    ]]  && bindkey  "${key[Left]}"    backward-char
[[ -n "${key[Right]}"   ]]  && bindkey  "${key[Right]}"   forward-char
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"    history-beginning-search-backward
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}"  history-beginning-search-forward

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init () {
        printf '%s' "${terminfo[smkx]}"
    }
    function zle-line-finish () {
        printf '%s' "${terminfo[rmkx]}"
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi

## COMPLETION ##
zsh_complete_tmux_list () {
	reply=(` tmux ls |
		cut -d: -f1 |
		sort`)
}
zsh_get_host_list () {
	reply=(`dig axfr ouraynet.com @ns1.ouraynet.com|
		pcregrep '^[a-z]\w*\.ouraynet\.com'|
		cut -d\. -f1`)
}
zsh_get_user_list () {
	reply=(`cat /etc/passwd |
		 awk -F: '{print $1 ":" $4}'`)
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
zsh_get_initlist () {
	reply=(--list `chkconfig --list|cut -d\  -f1`)
}
compctl -K zsh_get_picture_dirs pcd
compctl -K zsh_complete_tmux_list tmux t tx
compctl -K zsh_get_initlist -k '(on off del)' chkconfig
compctl -x 'p[1]' -K zsh_get_user_list - 'p[2], p[3]' -f -- chown
compctl -x 'p[1]' -K zsh_get_host_list - 'p[3]' -K zsh_get_user_list -- ssh
compctl -x 'p[1]' -K zsh_get_host_list -- ping
compctl -g "*(-/) .*(-/)" cd rmdir
compctl -g "*.gz *.tgz" + -g "*(-/) .*(-/)" gunzip
compctl -g "*.zip" + -g "*(-/) .*(-/)" unzip
compctl -g "*.mp3 *.mp2" + -g "*(-/) .*(-/)" mpg123 freeamp xmms x11amp
compctl -u -x 's[+] c[-1,-f],s[-f+]' -W ~/Mail -f - 's[-f],c[-1,-f]' -f -- mail elm su
compctl -u passwd be
compctl -k '(next count)' wmail
#compctl -k '(help commit checkout status update diff list)' svn
compctl -g "*.rpm" + -g "*(-/) .*(-/)" rpm2cpio rpm
compctl -g "*.tgz *.tar.gz *.rpm" + -g "*(/) .*(/)" rpmbuild
compctl -j -P '%' + -s '`ps -x | tail +2 | cut -c1-5`' + -x 's[-] p[1]' -k "($signals[1,-3])" -- kill
compctl -x 'w[0,sudo]' -l '' --  sudo
compctl -x 'w[0,time]' -l '' --  time
compctl -x 'w[0,watch]' -l '' --  watch
compctl -x 'w[0,xargs]' -l '' --  xargs
compctl -c man
compctl -z fg
compctl -g "*.deb *.rpm *.tgz" + -g "*(-/) .*(-/)" alien
compctl -g "*.exe *.Exe *.EXE" + -g "*(-/) .*(-/)" wine

if [[ $TERM_PROGRAM == "iTerm.app" ]]; then
	alias v="mvim --remote-tab-silent"
elif false; then
	alias v="givm --remote-tab-silent"
else
	alias v=$VISUAL
fi

t () {
	print -Pn "]0;%m:$1"
	tmux attach -d -t $1 || tmux new -s $1
}

ts () {
	print -Pn "]0;%m:$1"
	tmux attach -t $1
}

tx () {
	print -Pn "]0;%m:$1"
	old_sessions=$(tmux ls 2>/dev/null | egrep "^[0-9]{14}.*[0-9]+\)$" | cut -f 1 -d:)
	for old_session_id in $old_sessions; do
		tmux kill-session -t $old_session_id
	done
	session_id=$(date +%Y%m%d%H%M%S)
	tmux new-session -d -t $1 -s $session_id
	tmux attach-session -t $session_id
	tmux kill-session -t $session_id
}

trim() {
	echo $1
}

if [ -f /etc/pld-release ]; then
	# Ubuntu's which is too dumb for this stuff
	alias which='alias | command which --read-alias --show-dot --show-tilde'
fi

# Typing convenience aliases
alias h="vcsh"
compdef h="vcsh"

case $(uname -s) in
	Darwin)
		lscolor='-G'
		;;
	Linux)
		lscolor='--color=auto'
		;;
esac
alias tl='tmux ls | cut -d: -f1 | sort'
alias l="ls -al $lscolor"
alias ls="ls -BF $lscolor"
alias ll="ls -l $lscolor"
alias la="ls -a $lscolor"
alias lv="ls -al $lscolor|less"
alias ..='cd ..'
alias br='sudo -s'
alias uh="sudo /usr/local/bin/triggers/update_host.zsh"


# Default argument aliases
alias less='less -X -M -r'
alias mkiso='mkisofs -J -r -joliet-long -o'

# Convenience functions
alias fit="cut -b1-$COLUMNS"
alias svndiff="svn diff -x -b | colordiff"
alias cvsdiff="cvs diff -u | colordiff"
alias gitdiff="git diff | colordiff"
alias bzrdiff="bzr diff | colordiff"

alias poldek="poldek --cachedir=$HOME/tmp/poldek-cache-$USER-$HOSTNAME"
alias ya="yaourt --noconfirm"

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

git () {
	case "$PWD"; in
		$HOME/rpm/*)
			command git -c user.email=$USER@pld-linux.org "$@"
			;;
		*)
			command git "$@"
			;;
	esac
}

svneditlog () {
	rev=$1
	if ! echo $rev | pcregrep '^[0-9]+$'; then
		echo "Invalid usage. svneditlog REV"
		return
	fi
	svn info | grep ^URL: | awk '{print $2}' | read url
	svn propedit -r $rev --revprop svn:log $url
}

svnlist () {
	if [ -z "$2" ]; then
		case $1 in
			clobered)
				svn status | grep '^~' | cut -c9-
				;;
			missing)
				svn status | grep '^\!' | cut -c9-
				;;
			unknown)
				svn status | grep '^\?' | cut -c9-
				;;
			conflicted)
				svn status | grep '^C' | cut -c9-
				;;
		esac
	else
		case $2 in
			add)
				$0 unknown | xargs -iX svn add "X"
				;;
			del)
				$0 missing | xargs -iX svn del "X"
				;;
			revert) $0 conflicted | xargs -iX svn revert "X"
				;;
			resolved) $0 conflicted | xargs -iX svn resolved "X"
				;;
			unclober)
				mkdir _tmp
				$0 clobered | while read item; do
					mv "$item" _tmp
					svn del "$item"
				done
				svn ci -m "Unclobering files. (removing old)"
				mv _tmp/* .
				rmdir _tmp
				$0 unknown add
				svn ci -m "Unclobering files. (adding new)"
				;;
		esac
	fi
}
compctl -x 'p[1]' -k '(missing unknown conflicted clobered)' - 'p[2]' -k '(add del revert resolved)' -- svnlist

pharmacyadmin () {
	host=$1
	ssh -f -L 7447:$host:5900 pharmacy sleep 5
	vncviewer localhost::7447 -encodings tight -bgr233 -passwd ~/.vnc/pharmacy
}
compctl -x 'p[1]' -k '(breakroom office1 office2 pharm2 pharm3 pharm5 workstation et et2 unknown pos2 pos3 posserver cl)' -- pharmacyadmin

go () {
	[ -d ~/projects/$1 ] && cd ~/projects/$1 && return
	[ -d ~/projects/websites/$1 ] && cd ~/projects/websites/$1 && return
	reply=($(find ~/projects ~/projects/websites -maxdepth 1 -mindepth 1 -type d -exec basename {} \; 2>/dev/null))
}

compctl -K go go

if [ -d ~/.ec2/ec2-api-tools ]; then
	export EC2_HOME=~/.ec2/ec2-api-tools
	export LIBDIR=$EC2_HOME/lib
	path=($path $EC2_HOME/bin)
fi

sourceifexists ~/.zshrc-private

case $HOSTNAME in
	leylek)
		;;
	lemur)
		alias burn='cdrecord -v dev=/dev/sr0 driveropts=burnfree'
		alias soundceptor='pacat -r -d alsa_output.pci-0000_00_14.2.analog-surround-50.monitor | sox -t raw -r 44100 -s -L -b 16 -c 2 - "output.wav"'
		;;
	pars)
		alias mplayer="mplayer -monitoraspect 3/4"
		alias burn='sudo cdrecord -v dev=/dev/hda driveropts=burnfree'
		alias dvdburn='dvdrecord -v dev=/dev/hda driveropts=burnfree'
		;;
	*)
		alias burn='cdrecord -v dev=/dev/sr0 driveropts=burnfree'
		function drivetemps () {
			for i in a b c d e; do sudo smartctl --all /dev/sd$i | grep Temperature_Celsius; done
		}
		;;
esac

compdef burn='cdrecord'

# black red green yellow blue magenta cyan white
case $HOSTNAME in
camelion|iguana|basilisk) local hostcolor=yellow ;;
	ns*|*server|mysql|sub|mail|*spam) local hostcolor=red ;;
	goose|gander) local hostcolor=blue;;
	leylek|lemur|pars|jaguar|karabatak|shrimp|lobster|oyster|hare) local hostcolor=cyan ;;
	*) local hostcolor=magenta ;;
esac

merge_rpmnew () {
	vim -d $1{,.rpmnew} && rm -i $1.rpmnew
}


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

accept-line() { prev_mode=$KEYMAP; zle .accept-line }
zle-line-init() { zle -K ${prev_mode:-viins} }
zle -N accept-line
zle -N zle-line-init

export KEYTIMEOUT=1

#~caleb/bin/knockknock.zsh
