#
# Defines environment variables.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

# Skip old configs for now
return

typeset -U path
path=(~/bin $path /usr/local/bin /bin /usr/bin /usr/local/sbin /sbin /usr/sbin:/usr/X11R6/bin)
