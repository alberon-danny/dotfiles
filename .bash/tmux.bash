# Workaround for losing SSH agent connection when reconnecting tmux: update a
# symlink to the socket each time we reconnect and use that as the socket in
# every session. First we make sure there's a valid socket connecting us to the
# agent and it's not already pointing to the symlink, and there's no existing
# working symlink:
link="$HOME/.ssh/ssh_auth_sock"
if [ "$SSH_AUTH_SOCK" != "$link" -a -S "$SSH_AUTH_SOCK" -a ! -S "$link" ]; then
    # We also check if the agent has any keys loaded - PuTTY will still open an
    # agent connection even if we used password authentication
    if ssh-add -l >/dev/null 2>&1; then
        ln -nsf "$SSH_AUTH_SOCK" "$HOME/.ssh/ssh_auth_sock"
    fi
fi

# Now that's done we can use the symlink for every session
export SSH_AUTH_SOCK="$HOME/.ssh/ssh_auth_sock"

# tmux attach
alias tm='tmux -2 attach || tmux -2 new -s default'

# ssh + tmux
sshtm() {
    ssh -t "$@" "tmux -2 attach || tmux -2 new -s default || bash -l"
}
