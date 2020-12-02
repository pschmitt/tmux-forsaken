#!/usr/bin/env bash

# This will close all windows that are right to the current one
tmux_close_windows_to_the_right() {
  for win_id in $(tmux list-windows -F '#{window_active} #{window_id}' | \
                  awk '/^1/ { active=1; next } active { print $2 }')
  do
    tmux kill-window -t "$win_id"
  done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  tmux_close_windows_to_the_right
fi
