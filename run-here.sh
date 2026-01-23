#!/bin/bash
set -euo pipefail

DIR=""
PORT=""

USAGE="Run (web mode) OpenCode container runner.

Usage: run-here.sh [DIRECTORY] [--cwd <dir> | --directory <dir>] [--port <PORT>] [-h|--help]

DIRECTORY: optional, non-flag first argument or provided with --cwd/--directory flags
Flags:
  --cwd, --directory <dir>   Change to specified directory inside host before running
  --port <PORT>               Expose container port and set OPENCODE_SERVER_PORT
  -h, --help                  Show this help message

Examples:
  run-here.sh
  run-here.sh /path/to/project
  run-here.sh --cwd /path/to/project --port 8080
  run-here.sh --port 9000
"

show_help() {
  printf "%s\n" "$USAGE"
}

# Positional directory as first non-flag arg
if [[ $# -gt 0 ]]; then
  if [[ "$1" != -* ]]; then
    DIR="$1"
    shift
  fi
fi

# Parse options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    --cwd|--directory)
      if [[ -n "${2:-}" ]]; then
        DIR="$2"
        shift 2
      else
        echo "Error: $1 requires a directory argument" >&2
        exit 1
      fi
      ;;
    --port)
      if [[ -n "${2:-}" ]]; then
        PORT="$2"
        shift 2
      else
        echo "Error: --port requires a value" >&2
        exit 1
      fi
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *)
      # Non-flag argument after parsing? Break
      break
      ;;
  esac
done

# Change directory if requested
if [[ -n "${DIR:-}" ]]; then
  if [[ -d "$DIR" ]]; then
    cd "$DIR"
  else
    echo "Directory not found: $DIR" >&2
    exit 1
  fi
fi

HOST_PWD="$(pwd)"
CONTAINER_NAME="$(basename "$HOST_PWD")"

DOCKER_ARGS=( --rm -it -v "$HOST_PWD":/projects/"$CONTAINER_NAME" )

if [[ -n "${PORT:-}" ]]; then
  DOCKER_ARGS+=( -p "${PORT}":"${PORT}" )
  DOCKER_ARGS+=( -e OPENCODE_SERVER_PORT="${PORT}" )
else
  DOCKER_ARGS+=( -p 4096:4096 )
fi

docker run "${DOCKER_ARGS[@]}" opencode-web:latest