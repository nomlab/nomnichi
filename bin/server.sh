#!/bin/sh

################################################################
## Helper functions

print_error() {
  printf "$(color red)Error:$(color normal) $@"
} >&2

print_info() {
  printf "$(color green)Info:$(color normal) $@"
} >&2

# This predicate have to be located at the top-level,
# not in the shell function.
if [ -t 1 ]; then
  RUNNING_IN_TERMINAL="true"
fi

color () {
  local color="$1"

  # skip if not running in terminal
  if [ -z "$RUNNING_IN_TERMINAL" ]; then
    return 0
  fi

  local ncolors=$(tput colors)

  # skip if not support 8 colors
  if [ -z "$ncolors" ] || [ "$ncolors" -lt 8 ]; then
    return 0
  fi

  case "$color" in
    bold)      tput bold    ;;
    underline) tput smul    ;;
    standout)  tput smso    ;;
    normal)    tput sgr0    ;;
    black)     tput setaf 0 ;;
    red)       tput setaf 1 ;;
    green)     tput setaf 2 ;;
    yellow)    tput setaf 3 ;;
    blue)      tput setaf 4 ;;
    magenta)   tput setaf 5 ;;
    cyan)      tput setaf 6 ;;
    white)     tput setaf 7 ;;
    *)         ;;
  esac
  return 0
}

################################################################
## Usage

usage () {
  echo "$(basename $0) {{start|restart} {development|production} | stop}"
} >&2


################################################################
## Test functions

PID_FILE="$(dirname $0)/../tmp/pids/server.pid"

server_pid () {
  if server_alive; then
    cat "$PID_FILE"
    return 0
  fi
  return 1
}

server_alive () {
  test -f "$PID_FILE"
}

################################################################
## main

do_start () {
  local environment="$1"

  if server_alive; then
    print_error "already running pid=$(server_pid).\n"
    return 1
  fi

  print_info "invoking...\n"

  export RAILS_RELATIVE_URL_ROOT='/lab/nom'
  export RAILS_SERVE_STATIC_FILES=true

  case "$environment" in
    dev*)
      export RAILS_ENV="development"
      export SERVER_PORT=3000
      ;;
    pro*)
      export RAILS_ENV="production"
      export SERVER_PORT=54321
      bundle exec rake assets:precompile RAILS_ENV="$RAILS_ENV"
      ;;
    *)
      usage
      return 1
      ;;
  esac

  bundle exec rails server -b 0.0.0.0 -p "$SERVER_PORT" -d -e "$RAILS_ENV"
  print_info "done.\n"
  return 0
}

do_stop () {
  local environment="$1"

  if server_alive; then
    print_info "stopping $(server_pid)..."
    kill $(server_pid)
    printf "done.\n"
    return 0
  else
    print_error "no server is running.\n"
    return 1
  fi
}

do_restart () {
  local environment="$1"

  do_stop "$environment"
  sleep 3
  do_start "$environment"
}

case $1 in
  start)
    do_start "$2"
    ;;
  stop)
    do_stop "$2"
    ;;
  restart)
    do_restart "$2"
    ;;
  *)
    usage
    exit 1
    ;;
esac

exit $?
