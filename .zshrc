sourceifexists () {
	[[ -s "$1" ]] && source "$1"
}

sourceifexists /usr/share/fonts/awesome-terminal-fonts/fontawesome-regular.sh

# {{{ Source Prezto
sourceifexists "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
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

# Add extra bindings for modules loaded by zprezto
# (currently conflicting with tmux/vim split navigation, using cmd mode anyway)
#bindkey -M viins "^K" history-substring-search-up
#bindkey -M viins "^J" history-substring-search-down

# {{{ These doesn't get set right on some of my systems
export HOSTNAME=${HOSTNAME:=${$(cat /etc/hostname)%%\.*}}
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

alias super-linter='docker run -e RUN_LOCAL=true -v "$(pwd):/tmp/lint" github/super-linter:latest'
alias fontship-docker='docker run -it --volume "$(pwd):/data" --user "$(id -u):$(id -g)" theleagueof/fontship:latest'
alias sile-docker='docker run -it --volume "$(pwd):/data" --user "$(id -u):$(id -g)" siletypesetter/sile:latest'

# {{{ Personal lazy aliases
alias ddstatus='sudo pkill -USR1 -x dd'
alias sc='sudo -E systemctl'
alias scu='systemctl --user'
alias jc='journalctl'
alias jcu='journalctl --user'
alias h="vcsh"
alias lv="l | less"
alias md2pdf="pandoc --latex-engine=xelatex -t latex"
alias gmv="noglob zmv -W"
alias add="paste -sd+ - | bc"
alias l="eza -lBF"
alias la="eza -alBF"
alias sort="sort -h"
alias dig="dig +noall +answer"

# Replace default apps with smart alternatives
alias cat="bat"
alias ls="eza"

# Note Git alias moved to .gitconfig [alias]
alias g="git"

# Remote Arch stuff
alias db-update="ssh repos.archlinux.org /community/db-update"

function tigl () {
	tig $(git branch --format='%(refname:short)') $@
}

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

trim() {
	echo $1
}

sourceiftext () {
	grep -q "$1" -- "$2" && source "$2"
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

docker-clean() {
  docker ps --no-trunc -aqf "status=exited" | xargs -r docker rm
  docker images --no-trunc -aqf "dangling=true" | xargs -r docker rmi
  docker volume ls -qf "dangling=true" | xargs -r docker volume rm
}

fetch_pkg_keys() {
	bash -ec 'source PKGBUILD; for k in ${validpgpkeys[@]}; do ssh build.archlinux.org gpg --recv-keys $k; gpg --recv-keys $k; done'
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
ffref () {
	sleep 0.25
	xdotool key --window $(xdotool search --name "Mozilla Firefox" | head -1) F5
}
# }}}

function drivetemps () {
	for drive in /dev/sd[a-z]; do sudo smartctl --all $drive | grep Temperature_Celsius; done
}

# {{{ Path fixes (and system specific hacks)

function addtopath () {
	[ -d $1 ] && path=($path $1)
}

# addtopath /usr/texbin
# addtopath ~/projects/android/sdk/tools
# addtopath /usr/local/apache-ant-1.6.5/bin
# addtopath /opt/android-sdk/platform-tools
# addtopath /opt/android-sdk/tools
# addtopath $(python -c "import site; print(site.getsitepackages()[0]+'/bin')")
# addtopath ~/projects/ipk/ceviriler/katip/bin
# addtopath ~/projects/viachristus/avadanlik/bin
addtopath ~/.cabal/bin
addtopath ~/node_modules/.bin
addtopath ~/.local/bin
addtopath ~/.cargo/bin

sourceifexists /home/caleb/.opam/opam-init/init.zsh

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

sourceiftext FIXER ~/.private/fixer_api.sh
sourceiftext DEEPL ~/.private/deepl_api.sh

case $HOSTNAME in
camelion|iguana|basilisk) local hostcolor=yellow ;;
	ns*|*server|mysql|sub|mail|*spam) local hostcolor=red ;;
	goose|gander) local hostcolor=blue;;
	leylek|lemur|pars|jaguar|karabatak|shrimp|lobster|oyster|hare) local hostcolor=cyan ;;
	*) local hostcolor=magenta ;;
esac
# }}}

# {{{ git-extras
sourceifexists "/usr/share/doc/git-extras/git-extras-completion.zsh"
#}}}

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

rga-fzf() {
	RG_PREFIX="rga --files-with-matches"
	local file
	file="$(
		FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
			fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
				--phony -q "$1" \
				--bind "change:reload:$RG_PREFIX {q}" \
				--preview-window="70%:wrap"
	)" &&
	echo "opening $file" &&
	xdg-open "$file"
}

# }}}

# Setup completion for remake
compdef _make remake
# alias make='remake'

# Sometimes GPG can't find it's own nose
export GPG_TTY=$(tty)

# Use bat as man pager
export MANROFFOPT='-c'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# added by travis gem
[ -f /home/caleb/.travis/travis.sh ] && source /home/caleb/.travis/travis.sh

export RIPGREP_CONFIG_PATH=~/.config/ripgreprc

export MAKEFLAGS="--jobs $(nproc)"

compinit

eval "$(starship init zsh)"

eval "$(atuin init zsh --disable-up-arrow)"

eval "$(zoxide init zsh)"

# vim: foldmethod=marker
