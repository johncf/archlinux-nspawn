#
# ~/.bashrc
#

export EDITOR=nvim

# If not running interactively, stop here
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias ll='ls -lAh'
alias cp="cp --reflink=auto"
export PS1='\[\e[38;5;203m\]\u\[\e[m\]@\[\e[38;5;38m\]\h \[\e[38;5;71m\]\w \n\[\e[38;5;185m\]\A \[\e[38;5;9m\]\$\[\e[m\] '

export HISTCONTROL=erasedups:ignorespace
export HISTSIZE=768
export HISTFILESIZE=1536
shopt -s histappend
