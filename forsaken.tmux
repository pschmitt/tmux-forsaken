#!/usr/bin/env bash

get_tmux_option() {
  local option="$1"
  local default_value="$2"
  local raw_value

  raw_value=$(tmux show-option -gqv "$option")

  echo "${raw_value:-$default_value}"
}

main() {
  local -a action
  local confirm_kill_empty_panes
  local confirm_kill_windows_ttr
  local key_kill_empty_panes
  local key_kill_windows_ttr
  local message
  local swd

  swd="$(readlink -f "$(dirname "$0")")/scripts"

  key_kill_empty_panes="$(get_tmux_option @forsaken-kill-empty-panes)"
  key_kill_windows_ttr="$(get_tmux_option @forsaken-kill-windows-ttr)"
  confirm_kill_empty_panes="$(get_tmux_option @forsaken-kill-empty-panes-confirm)"
  confirm_kill_windows_ttr="$(get_tmux_option @forsaken-kill-windows-ttr-confirm)"

  if [[ -n "$key_kill_empty_panes" ]]
  then
    action=(run-shell -b "${swd}/tmux-kill-empty-panes.sh")

    case "$confirm_kill_empty_panes" in
      1|yes|true)
        message="Kill all empty panes?"
        ;;
      *)
        message="$confirm_kill_empty_panes"
        ;;
    esac

    tmux unbind "$key_kill_empty_panes"

    if [[ -n "$message" ]]
    then
      action=(confirm-before -p "$message" "${action[*]}")
    fi

    tmux bind-key "$key_kill_empty_panes" "${action[@]}"

    message=""
  fi

  if [[ -n "$key_kill_windows_ttr" ]]
  then
    action=(run-shell -b "${swd}/tmux-kill-windows-to-the-right.sh")

    case "$confirm_kill_windows_ttr" in
      1|yes|true)
        message="Kill all windows to the right?"
        ;;
      *)
        message="$confirm_kill_windows_ttr"
        ;;
    esac

    tmux unbind "$key_kill_windows_ttr"

    if [[ -n "$message" ]]
    then
      action=(confirm-before -p "$message" "${action[*]}")
    fi

    tmux bind-key "$key_kill_windows_ttr" "${action[@]}"

    message=""
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  main
fi
