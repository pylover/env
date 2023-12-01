shopt -s expand_aliases

alias la="ls -lah"
alias clip="xclip -selection c $@"
alias grep="grep --color=always $@"
alias open="xdg-open $@"

# Wireguard
aliad wgon="/usr/loca/bin/wgctl up"
aliad wgoff="/usr/loca/bin/wgctl down"
