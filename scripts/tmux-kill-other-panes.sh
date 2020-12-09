#!/usr/bin/env bash

tmux_kill_other_panes() {
  local pane_id

  for pane_id in $(tmux list-panes -F '#{pane_active} #{pane_id}' |
                   awk '!/^1 / { print $2 }')
  do
    tmux kill-pane -t "$pane_id"
  done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  tmux_kill_other_panes
fi
