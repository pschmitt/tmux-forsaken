#!/usr/bin/env bash

get_tmux_option() {
  local option="$1"
  local default_value="$2"
  local raw_value

  raw_value=$(tmux show-option -gqv "$option")

  echo "${raw_value:-$default_value}"
}

main() {
  local key_kill_empty_panes
  local key_kill_windows_ttr
  local swd

  swd="$(readlink -f "$(dirname "$0")")/scripts"

  key_kill_empty_panes="$(get_tmux_option @forsaken-kill-empty-panes)"
  key_kill_windows_ttr="$(get_tmux_option @forsaken-kill-windows-ttr)"

  if [[ -n "$key_kill_windows_ttr" ]]
  then
    tmux bind-key "$key_kill_windows_ttr" run-shell -b "${swd}/tmux-kill-windows-to-the-right.sh"
  fi

  if [[ -n "$key_kill_empty_panes" ]]
  then
    tmux bind-key "$key_kill_empty_panes" run-shell -b "${swd}/tmux-kill-empty-panes.sh"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  main
fi
