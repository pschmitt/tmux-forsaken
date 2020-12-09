#!/usr/bin/env bash

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=rate-pane.sh disable=1091
source "${CWD}/rate-pane.sh"

# This will close all windows that are right to the current one
# shellcheck disable=2120
tmux_close_windows_to_the_right() {
  local win_id
  local safe_mode
  local complexity
  local is_active

  case "$1" in
    --safe|-s|--rate|-r)
      safe_mode=1
      ;;
  esac

  for win_id in $(tmux list-windows -F '#{window_active} #{window_id}' | \
                  awk '/^1/ { active=1; next } active { print $2 }')
  do
    if [[ -n "$safe_mode" ]]
    then
      for pane_id in $(tmux list-panes -t "${win_id}" -F '#{pane_id}')
      do
        # Reset is_active
        is_active=
        echo "Resetting is_active: $is_active and processing $pane_id" >&2

        # if complexity="$(TMUX_SESSION="$session" tmux_rate_pane "$pane_id")"
        if complexity="$(tmux_rate_pane "$pane_id")"
        then
          is_active=1
          # Break since we do not need process any more panes
          break
        elif [[ -z "$complexity" ]] || ! [[ "$complexity" =~ ^[0-9]+$ ]]
        then
          {
            echo -e "\e[91mRating failed."
            echo "Please re-run with DEBUG=1 and create a GitHub issue: "
            echo -e "https://github.com/pschmitt/tmux-forsaken/issues/new\e[0m"
          } >&2
          return 3
        fi
      done

      if [[ -n "$is_active" ]]
      then
        echo "NOT killing window ${win_id} since at least one of its panes" \
             "is running something" >&2
        continue
      else
        echo "Killing window ${win_id} (no pane activity)" >&2
      fi
    fi

    tmux kill-window -t "$win_id"
  done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  tmux_close_windows_to_the_right "$@"
fi
