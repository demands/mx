#!/usr/bin/env bash

set -o errexit
set -o nounset

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
TEST_DIR="$BASE_DIR/test"
STUBS_DIR=$TEST_DIR/stubs
MOCKS_DIR=$TEST_DIR/mocks

MX=$BASE_DIR/bin/mx

export PATH=$STUBS_DIR:$PATH
export TMUX='foo' # pretend to be in a tmux session even if we aren't
export PROJECTS=$MOCKS_DIR/projects

source $TEST_DIR/tap.sh

run_mx() {
  IFS=$'\n'
  if INVOCATIONS=($($MX "$@")); then
    LAST_RUN=$?
  else
    LAST_RUN=$?
  fi
  unset IFS

  # for i in "${INVOCATIONS[@]}"; do
  #   echo $i
  # done
}

expect_successful_run() {
  if [[ $LAST_RUN -eq 0 ]]; then
    tap_success "mx ran successfully"
  else
    tap_failure "mx failed with status $LAST_RUN"
  fi
}

expect_invocation_to_have_argument() {
  local subcmd=$1
  local arg=$2
  local invocation

  for invocation in "${INVOCATIONS[@]}"; do
    if [[ $invocation =~ $subcmd ]]; then
      if [[ $invocation =~ $arg ]]; then
        tap_success "sub-command '$subcmd' had argument '$arg'"
      else
        tap_failure "sub-command '$subcmd' did not have argument '$arg'"
      fi
      return 0
    fi
  done
  tap_failure "sub-command '$subcmd' was never invoked"
}

expect_no_invocation() {
  local subcmd=$1

  for invocation in "${INVOCATIONS[@]}"; do
    if [[ $invocation =~ $subcmd ]]; then
      tap_failure "sub-command '$subcmd' was invoked"
      return 0
    fi
  done
  tap_success "sub-command '$subcmd' was not invoked"
}
