#!/usr/bin/env bash

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=rate-pane.sh disable=1091
source "${CWD}/rate-pane.sh"

tmux_get_current_session() {
  tmux display-message -p '#S'
}

tmux_kill_empty_panes() {
  local complexity
  local killed_panes=()
  local pane_id
  local session

  session="$(tmux_get_current_session)"

  while read -r pane_id
  do
    if complexity=$(tmux_rate_pane "$pane_id")
    then
      if [[ -n "$DEBUG" ]]
      then
        echo -e "\e[35m  -> SKIP (Complexity: $complexity)\e[0m" >&2
      fi
    else
      if [[ -n "$DEBUG" ]]
      then
        echo -e "\e[91m  -> Kill pane $pane_id (Complexity: ${complexity})\e[0m" >&2
      fi

      if tmux kill-pane -t "$pane_id"
      then
        killed_panes+=("$pane_id")
      fi
    fi
  # The awk filter prevents us from killing the currently active pane
  done < <(tmux list-panes -s -t "$session" \
    -F '#{pane_id} #{pane_active} #{window_active}' | \
    awk '!/1 1$/ { print $1 }')

  if [[ ${#killed_panes[@]} -gt 0 ]]
  then
    echo "💀 Killed ${#killed_panes[@]} panes"
  else
    echo "👍 No pane was harmed during the execution of this script" >&2
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  case "$1" in
    --debug|-d|debug|dbg|d)
      DEBUG=1
      shift
      ;;
  esac

  tmux_kill_empty_panes "$@"
fi
