# tmux-forsaken

This tpm plugins provides two scripts:

1. `tmux-kill-empty-panes.sh`
2. `tmux-kill-window-to-the-right.sh`


# Installation

Using [TPM](https://github.com/tmux-plugins/tpm):

```
set -g @plugin 'pschmitt/tmux-forsaken'
```

## Configuration

To have this plugin do anything you need to at least set one of
`forsaken-kill-empty-panes` or `forsaken-kill-windows-ttr`.

They should contain the key that will be bound to respectively killing all
empty panes and killig all windows right to the currently active one.
