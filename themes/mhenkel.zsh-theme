function prompt_char {
    git branch >/dev/null 2>/dev/null && echo '±' && return
    hg root >/dev/null 2>/dev/null && echo '☿' && return
    echo '○'
}

function battery_charge {
    echo `$BAT_CHARGE` 2>/dev/null
}

function virtualenv_info {
    [ $VIRTUAL_ENV ] && echo '('`basename $VIRTUAL_ENV`') '
}

function hg_prompt_info {
    hg prompt --angle-brackets "\
< on %{$fg[magenta]%}<branch>%{$reset_color%}>\
< at %{$fg[yellow]%}<tags|%{$reset_color%}, %{$fg[yellow]%}>%{$reset_color%}>\
%{$fg[green]%}<status|modified|unknown><update>%{$reset_color%}<
patches: <patches|join( → )|pre_applied(%{$fg[yellow]%})|post_applied(%{$reset_color%})|pre_unapplied(%{$fg_bold[black]%})|post_unapplied(%{$reset_color%})>>" 2>/dev/null
}

PROMPT='
%{$fg[magenta]%}%n%{$reset_color%}@%{$fg[yellow]%}%m%{$reset_color%} in %{$fg_bold[green]%}${PWD/#$HOME/~}%{$reset_color%}$(hg_prompt_info)$(git_prompt_info)
$(virtualenv_info)$(prompt_char) '

#RPROMPT='$(battery_charge)'
RPROMPT='%{$fg[green]%}%*%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[magenta]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""

# When running commands with sudo display the user and host,
# as well as the full command. The default omz behavior is
# to not show the hosh/user while running a command, and to
# strip the word sudo from CMD strings. We'll override
# cmz_termsupport_precmd, falling back to the original function,
# to achieve this.

# First make a backup of the existing preexec command. We do this
# conditionally to prevent sourcing this file again from putting
# us in a recursive state.
if [ ! -n  "$(functions mnh_orig_omz_termsupport_preexec)" ]; then
  autoload -U regexp-replace

  mnh_orig_omz_termsupport_preexec=$(
    functions omz_termsupport_preexec
  );
  regexp-replace mnh_orig_omz_termsupport_preexec '^omz_termsupport_preexec' 'function mnh_orig_omz_termsupport_preexec'
  eval $mnh_orig_omz_termsupport_preexec
fi

# Now replace the preexec command with our version, using the oiginal
# if the current command doesn't start with sudo.
function omz_termsupport_preexec {
  emulate -L zsh
  setopt extended_glob

  if [[ $1 =~ "^sudo " ]]; then
    local CMD="$ZSH_THEME_TERM_TITLE_IDLE ${1:gs/%/%%}"
    local LINE="$ZSH_THEME_TERM_TITLE_IDLE ${2:gs/%/%%}"

    title '$CMD' '%100>...>$LINE%<<'
  else
    mnh_orig_omz_termsupport_preexec
  fi
}
