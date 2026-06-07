# ~/.zprofile — sourced for zsh login shells (macOS default shell).
# Mirrors ~/.bash_profile: pulls in the shared shell-neutral login config.
# brew shellenv, PATH, pyenv/nvm init and helper functions all live there,
# so there is no duplication between bash and zsh.

[ -f ~/.shell_common.sh ] && source ~/.shell_common.sh
