autoload -Uz colors && colors

# Handle variable substitution in the PROMPT string
setopt prompt_subst

# Enable the vcs_info module so we can make PROMPT VCS aware
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn bzr

disp () {
	export DISPLAY=$1:0.0
}

tetherbot() {
	adb forward tcp:1080 tcp:1080
	adb forward tcp:1081 localabstract:Tunnel
	tsocks on
}

auth () {
	ssh-agent
	ssh-add ~/.ssh/id_rsa
	sudo echo -n
}

authi () {
	ssh-agent | source /dev/stdin
	ssh-add ~/.ssh/id_rsa
	sudo echo -n
}

lineTrim () {
	bottom=$2
	let top=$bottom-$1+1
	head -n $bottom | tail -n $top
}

sourceifexists () {
	[ -f "$1" ] && source "$1"
}

preexec() {
	# Giv tmux some info on what is running in the shell before we go off and do it
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

pprint () {
	cat $1 | fmt -s -u -w 75 | lpr
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

cleanpath () {
	echo $PATH |
		perl -pne 's/:/\n/g' |
		awk '!x[$0]++' |
		perl -pne 's/\n/:/g' | read PATH
	export PATH
}
	
unset MAIL MAILCHECK MAILPATH
HISTSIZE=50000
SAVEHIST=50000
EDITOR=vim
VISUAL=vim
PAGER='less -r'
PATH=~/bin:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/usr/X11R6/bin:.:/home/users/caleb/projects/android/sdk/tools

[ -d /usr/local/apache-ant-1.6.5 ] && PATH=$PATH:/usr/local/apache-ant-1.6.5/bin

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
%f%# '
RPROMPT='%F{black}%*'
cleanpath
PICTUREDIR=/pictures
THUMBDIR=/pictures/thumbs

export HISTSIZE HISTFILE SAVEHIST PROMPT RPROMPT EDITOR VISUAL PAGER PATH

umask 022

#setopt NOTIFY
#setopt HIST_IGNORE_SPACE
#setopt HIST_IGNORE_DUPS
setopt autocd
setopt pushdignoredups
setopt histignoredups
#setopt interactivecomment

setopt -o extended_glob

#no console beep
echo -en "[11;0]"

bindkey -v
bindkey '^L' push-line
bindkey "\e[1~" beginning-of-line
bindkey "^[[H" beginning-of-line
bindkey "\e[2~" transpose-words
bindkey "\e[3~" delete-char
bindkey "\e[4~" end-of-line
bindkey "\e[F" end-of-line

mkdir -p /tmp/screen.$USER
chmod 700 /tmp/screen.$USER
export SCREENDIR=/tmp/screen.$USER

## COMPLETION ##
zsh_complete_screen_list () {
	reply=(` screen -list |
		grep \( |
		perl -pne "s!.*\.(\w*)\s.*!\1!g;s!\s+! !g" |
		sort`)
}
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
compctl -K zsh_complete_screen_list screen s sx
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

s () {
	print -Pn "]0;%m:$1"
	SCREEN=$1 screen -d -RR $1
}
sx () {
	print -Pn "]0;%m:$1"
	SCREEN=$1 screen -x $1
}
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
alias sl='screen -list | grep \( | perl -pne "s!.*\.(\w*)\s.*!\1!g" | sort'
alias tl='tmux ls | cut -d: -f1 | sort'
alias l='ls -al --color=auto'
alias ls='ls -BF --color=auto'
alias ll='ls -l --color=auto'
alias la='ls -a --color=auto'
alias lv='ls -al --color=auto|less'
alias ..='cd ..'
if [ -f /etc/pld-release ]; then
	# Ubuntu's which is too dumb for this stuff
	alias which='alias | /usr/bin/which --read-alias --show-dot --show-tilde'
fi
alias su='su'
alias br='SCREEN=$SCREEN sudo -s'
alias rm='rm -i'
alias less='less -X -M -r'
alias lad='{find . -type d -maxdepth 1|sort -fn|xargs ls -aldF --color;find . -type f -maxdepth 1 |sort -fn|xargs ls -alF --color}|sed "s!./!!g"|grep -v "~"'
alias lpr='lpr -P hpc5m@server'
#alias compupic='LD_LIBRARY_PATH=/usr/local/compupic compupic'
alias mkiso='mkisofs -J -r -joliet-long -o'
alias fit="cut -b0-$(($COLUMNS-1))"
alias uh="sudo /usr/local/bin/triggers/update_host.zsh"
alias svndiff="svn diff -x -b | colordiff"
alias cvsdiff="cvs diff -u | colordiff"
alias gitdiff="git diff | colordiff"
alias bzrdiff="bzr diff | colordiff"

alias poldek="poldek --cachedir=$HOME/tmp/poldek-cache-$USER-$HOSTNAME"

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

alias ssl='svn status --ignore-externals'
alias svndiff='svn diff -x -b | colordiff'

pharmacyadmin () {
	host=$1
	ssh -f -L 7447:$host:5900 pharmacy sleep 5
	vncviewer localhost::7447 -encodings tight -bgr233 -passwd ~/.vnc/pharmacy
}
compctl -x 'p[1]' -k '(breakroom office1 office2 pharm2 pharm3 pharm5 workstation et et2 unknown pos2 pos3 posserver cl)' -- pharmacyadmin

compctl -x 'p[1]' -k '(missing unknown conflicted clobered)' - 'p[2]' -k '(add del revert resolved)' -- svnlist

go () {
	[ -d ~/projects/$1 ] && cd ~/projects/$1 && return
	[ -d ~/projects/websites/$1 ] && cd ~/projects/websites/$1 && return
	reply=(`/bin/ls ~/projects && /bin/ls ~/projects/websites`)
}

compctl -K go go

export EC2_HOME=~caleb/.ec2/ec2-api-tools
export PATH=$PATH:$EC2_HOME/bin
export LIBDIR=$EC2_HOME/lib

sourceifexists ~/.zshrc-private

case $HOSTNAME in
	lemur)
		alias burn='cdrecord -v dev=/dev/sr0 driveropts=burnfree'
		alias soundceptor='pacat -r -d alsa_output.pci-0000_00_14.2.analog-surround-50.monitor | sox -t raw -r 44100 -s -L -b 16 -c 2 - "output.wav"'
		function drivetemps () {
			for i in a b c d e; do sudo smartctl --all /dev/sd$i | grep Temperature_Celsius; done
		}
		;;
	ibex)
		#alias mplayer="mplayer -monitoraspect 1"
		alias burn='cdrecord -v dev=/dev/sr0 driveropts=burnfree'
		alias dvdburn='dvdrecord -v dev=/dev/sr0 driveropts=burnfree'
		function projector () {
			case $1 in
				on)
					xrandr --auto
					xrandr --output VGA1 --right-of LVDS
					;;
				off)
					xrandr --output VGA1 --off
					;;
			esac
		}
		;;
	pars)
		alias mplayer="mplayer -monitoraspect 3/4"
		alias burn='sudo cdrecord -v dev=/dev/hda driveropts=burnfree'
		alias dvdburn='dvdrecord -v dev=/dev/hda driveropts=burnfree'
		;;
	panther)
		alias burn='cdrecord -v dev=/dev/sr0 driveropts=burnfree'
		#alias burn='cdrecord -v dev=2,0,0 driveropts=burnfree'
		alias SL=~/downloads/secondlife/SecondLife_i686_1_18_3_5/secondlife
		;;
	viper)
		alias burn='cdrecord -v dev=/dev/hdc driveropts=burnfree'
		alias dvdburn='dvdrecord -v dev=/dev/hdc driveropts=burnfree'
		;;
	aspen)
		alias burn='cdrecord -v dev=/dev/hdd'
		alias copy_audio_cd='cdrdao copy --source-device /dev/hdc --device /dev/hdd --buffers 64'
		alias copy_data_cd='cat /dev/hdc > /tmp/copy.iso; burn /tmp/copy.iso'
		;;
	giraffe)
		alias burn='cdrecord -v dev=/dev/hdd'
		;;
	*)
		alias burn='cdrecord -v dev=/dev/cdrw'
		;;
esac

# black red green yellow blue magenta cyan white
case $HOSTNAME in
	camelion) local hostcolor=magenta ;;
	ns*|*server|mysql|sub|mail|*spam) local hostcolor=red ;;
	ferret|boa|kartal|goose|gander|beaver|chipmunk) local hostcolor=blue;;
	leylek|lemur|ibex|pars|panther|viper|giraffe) local hostcolor=cyan ;;
	*) local hostcolor=yellow ;;
esac

zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"

autoload -Uz compinit
compinit 2> /dev/null

dun_bluetooth () {
	rfcomm connect 0 00:14:9A:5A:23:15 8 &
}

merge_rpmnew () {
	vim -d $1{,.rpmnew} && rm -i $1.rpmnew
}

#~caleb/bin/knockknock.zsh
