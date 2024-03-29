#!/usr/bin/env bash

tmux_get_option() {
  tmux show-options -g | awk "/^${1} / {print \$2}"
}

tmux_get_current_session() {
  tmux display-message -p '#S'
}

tmux_get_default_shell() {
  local default_shell
  default_shell="$(tmux_get_option "default-shell")"

  if [[ -z "$default_shell" ]]
  then
    echo "Failed to determine default-shell. Defaulting to bash." >&2
    default_shell=bash
  fi

  case "$1" in
    --basename|-b|--strip|-s)
      basename "$default_shell"
      ;;
    *)
      echo "$default_shell"
      ;;
  esac
}

# shellcheck disable=2120
tmux_get_pane_cmd_info() {
  local pane_id="$1"
  local session
  session="${TMUX_SESSION:-${2:-$(tmux_get_current_session)}}"

  tmux list-panes -s -t "$session" \
    -F '#{pane_id} #{pane_pid} #{pane_current_command}' | \
    awk "/^${pane_id} / {print \$2, \$3}"
}

tmux_rate_pane() {
  local complexity
  local default_shell
  local max_complexity="${2:-4}"
  local pane_cmd
  local pane_id="$1"
  local pane_pid
  local rating_failed
  local tmp

  read -r pane_pid pane_cmd <<< "$(tmux_get_pane_cmd_info "$pane_id")"

  if [[ -n "$DEBUG" ]]
  then
    {
      echo -e "\e[34mRating pane $pane_id (PID: $pane_pid) [CMD: ${pane_cmd}]\e[0m"
      echo "$tmp"
    } >&2
  fi

  if ! tmp="$(ps --forest -o pid= -g "$pane_pid")"
  then
    echo "ps --forest -o pid= -g $pane_pid failed" >&2
    return 7
  fi

  default_shell="$(tmux_get_default_shell --basename)"
  complexity=$(wc -l <<< "$tmp")

  if [[ "$pane_cmd" == "$default_shell" ]] && \
     [[ "$complexity" -lt "$max_complexity" ]]
  then
    rating_failed=1
  fi

  # Return complexity
  echo "$complexity"

  [[ -z "$rating_failed" ]]
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  tmux_rate_pane "$@"
fi
