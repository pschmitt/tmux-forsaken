#!/usr/bin/env bash

tmux_get_option() {
  tmux show-options -g | awk "/^${1} / {print \$2}"
}

tmux_get_default_shell() {
  tmux_get_option "default-shell"
}

tmux_get_current_session() {
  tmux display-message -p '#S'
}

tmux_kill_empty_panes() {
  local complexity
  local default_shell
  local killed_panes=()
  local max_complexity="${1:-4}"
  local pane_cmd
  local pane_id
  local pane_pid
  local session
  local tmp

  session=$(tmux_get_current_session)
  default_shell=$(basename "$(tmux_get_default_shell)")

  if [[ -z "$default_shell" ]]
  then
    echo "Failed to determine default-shell. Defaulting to bash." >&2
    default_shell=bash
  fi

  while read -r _ pane_id pane_pid pane_cmd _ _
  do
    tmp=$(pstree -a -p -t "$pane_pid")

    if [[ -n "$DEBUG" ]]
    then
      {
        echo -e "\e[34mProcessing pane $pane_id (PID: $pane_pid) [CMD: ${pane_cmd}]\e[0m"
        echo "$tmp"
      } >&2
    fi

    complexity=$(wc -l <<< "$tmp")

    if [[ "$pane_cmd" == "$default_shell" ]] && \
       [[ "$complexity" -lt "$max_complexity" ]]
    then
      if [[ -n "$DEBUG" ]]
      then
        echo -e "\e[91m\$ Kill pane $pane_id (Complexity: ${complexity})\e[0m" >&2
      fi

      if tmux kill-pane -t "$pane_id"
      then
        killed_panes+=("$pane_pid")
      fi
    else
      if [[ -n "$DEBUG" ]]
      then
        echo -e "\e[35mSKIP (Complexity: $complexity)\e[0m\n" >&2
      fi
    fi
  # The grep -v '1 1$' prevents us from killing the currently active pane
  done < <(tmux list-panes -a \
    -F '#S #D #{pane_pid} #{pane_current_command} #{pane_active} #{window_active}' | \
    awk "/^${session} /" | grep -v '1 1$')

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
