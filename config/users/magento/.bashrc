export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export LANGUAGE=C.UTF-8

alias ls='ls --color=auto'
alias ll='ls --color=auto -l'
alias la='ls --color=auto -al'

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;33m\]\u@\h\[\033[00m\]\[\033[01;34m\] \w \$\[\033[00m\] '
