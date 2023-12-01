shopt -s expand_aliases

alias la="ls -lah"
alias clip="xclip -selection c $@"
alias grep="grep --color=always $@"
alias open="xdg-open $@"

# Wireguard
alias wgon="/usr/local/bin/wgctl up"
alias wgoff="/usr/local/bin/wgctl down"
