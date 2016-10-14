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
unsetopt autoremoveslash
unsetopt beep
unsetopt histbeep
unsetopt listbeep
unsetopt nomatch
unsetopt histverify
# }}}

# {{{ Source Powerline
# ...or not
#if [[ -s /usr/share/zsh/site-contrib/powerline.zsh ]]; then
  #source /usr/share/zsh/site-contrib/powerline.zsh
#fi
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
#bindkey -M viins "$key_info[Control]K" history-substring-search-up
#bindkey -M viins "$key_info[Control]J" history-substring-search-down

# {{{ These doesn't get set right on some of my systems
export HOSTNAME=${HOSTNAME:=${$(hostname)%%\.*}}
umask 022
# }}}

# {{{ Enable editing of current command in editor
autoload -z edit-command-line
zle -N edit-command-line
bindkey "$key_info[Control]E" edit-command-line
# }}}

# {{{ Extra bindings
bindkey "$key_info[Control]R" transpose-words

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

# {{{ Default argument functions
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
# }}}

# {{{ Personal lazy aliases
alias ddstatus='sudo pkill -USR1 -x dd'
alias sc='sudo systemctl'
alias scu='systemctl --user'
alias se='sudoedit'
alias h="vcsh"
alias lv="ls -al $lscolor|less"
alias md2pdf="pandoc --latex-engine=xelatex -t latex"
alias gcd="cd $(git getroot)"

if [[ $TERM_PROGRAM == "iTerm.app" ]]; then
	alias v="mvim --remote-tab-silent"
#elif [[ -n "$DESKTOP_SESSION" ]]; then
	#alias v="gvim -p --remote-tab-silent"
#elif [[ -n "$VISUAL" ]]; then
	#alias v=$VISUAL
elif command -v fasd >/dev/null; then
	alias v='f -e vim'
elif command -v nvim >/dev/null; then
	alias v=nvim
elif command -v vim >/dev/null; then
	alias v=vim
else
	alias v=vi
fi
# }}}

# {{{ Convenience functions
auth () {
	eval $(keychain --agents ssh,gpg --eval -Q --quiet ~/.ssh/id_rsa ~/.ssh/github ~/.ssh/aur 75267693 B89B1E86)
}
fit() {
	cat - | cut -b1-$COLUMNS
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
compdef yaourt='pacman'
alias ya='yaourt'
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

# {{{ Path fixes (and system specific hacks)

function addtopath () {
	[ -d $1 ] && path=($path $1)
}

addtopath /usr/texbin
addtopath ~/projects/android/sdk/tools
addtopath /usr/local/apache-ant-1.6.5/bin
addtopath /opt/android-sdk/platform-tools
addtopath /opt/android-sdk/tools
addtopath ~/projects/tprk/aletler/bin
addtopath ~/projects/viachristus/avadanlik/bin
addtopath ~/.cabal/bin

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
alias fzf='fzf-tmux'
source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh
fs() {
  local session
  session=$(tmux list-sessions -F "#{session_name}" | \
    fzf --query="$1" --select-1 --exit-0) &&
  tmux switch-client -t "$session"
}
ftpane () {
  local panes current_window target target_window target_pane
  panes=$(tmux list-panes -s -F '#I:#P - #{pane_current_path} #{pane_current_command}')
  current_window=$(tmux display-message  -p '#I')

  target=$(echo "$panes" | fzf) || return

  target_window=$(echo $target | awk 'BEGIN{FS=":|-"} {print$1}')
  target_pane=$(echo $target | awk 'BEGIN{FS=":|-"} {print$2}' | cut -c 1)

  if [[ $current_window -eq $target_window ]]; then
    tmux select-pane -t ${target_window}.${target_pane}
  else
    tmux select-pane -t ${target_window}.${target_pane} &&
    tmux select-window -t $target_window
  fi
}
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

# Skip old configs for now
return

# {{{ -- Old unrefactored bits

# Enable the vcs_info module so we can make PROMPT VCS aware
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn

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

unset MAIL MAILCHECK MAILPATH
HISTSIZE=50000
SAVEHIST=50000

preexec() {
	# Give tmux some info on what is running in the shell before we go off and do it
	if [ -n "$TMUX_PANE" ]; then
		cmd=${2[(w)1]}
		print -Pn "k$cmd\\"
	fi
}

precmd () {
	vcs_info
	if [ -n "$TMUX_PANE" ]; then
		print -Pn "k \\"
	fi
	case $TERM in
		xterm*)
			print -Pn "]0;%m"
		;;
	esac
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

# Typing convenience aliases
alias tl='tmux ls | cut -d: -f1 | sort'
alias l="ls -al $lscolor"
alias ls="ls -BF $lscolor"
alias la="ls -a $lscolor"
alias br='sudo -s'
alias uh="sudo /usr/local/bin/triggers/update_host.zsh"

# Convenience functions
alias svndiff="svn diff -x -b | colordiff"
alias cvsdiff="cvs diff -u | colordiff"
alias gitdiff="git diff | colordiff"
alias bzrdiff="bzr diff | colordiff"

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

case $HOSTNAME in
	leylek)
		;;
	lemur)
		alias burn='cdrecord -v dev=/dev/sr0 driveropts=burnfree'
		alias soundceptor='pacat -r -d alsa_output.pci-0000_00_14.2.analog-surround-50.monitor | sox -t raw -r 44100 -s -l -b 16 -c 2 - "output.wav"'
		;;
	pars)
		alias mplayer="mplayer -monitoraspect 3/4"
		alias burn='sudo cdrecord -v dev=/dev/hda driveropts=burnfree'
		alias dvdburn='dvdrecord -v dev=/dev/hda driveropts=burnfree'
		;;
	*)
		alias burn='cdrecord -v dev=/dev/sr0 driveropts=burnfree'
		function drivetemps () {
			for i in a b c d e; do sudo smartctl --all /dev/sd$i | grep temperature_celsius; done
		}
		;;
esac

merge_rpmnew () {
	vim -d $1{,.rpmnew} && rm -i $1.rpmnew
}

accept-line() { prev_mode=$KEYMAP; zle .accept-line }
zle-line-init() { zle -K ${prev_mode:-viins} }
zle -N accept-line
zle -N zle-line-init

export KEYTIMEOUT=1

# }}}

#~caleb/bin/knockknock.zsh
# vim: foldmethod=marker

# added by travis gem
[ -f /home/caleb/.travis/travis.sh ] && source /home/caleb/.travis/travis.sh
