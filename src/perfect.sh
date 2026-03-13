#!/usr/bin/env bash
set -euo pipefail

VERSION="@@VERSION@@"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PERFECT_DIR="$PWD/.perfect"
GENERATED_SPECS_DIR="$PERFECT_DIR/generated_specs"
ACTUALIZED_IMPL_DIR="$PERFECT_DIR/actualized_implementations"

# --- Spec Validation ---

validate_spec() {
  local spec_path="$1"

  echo "[validate] Validating specification: $spec_path"

  if [[ ! -e "$spec_path" ]]; then
    echo "[validate] FAILED: '$spec_path' does not exist" >&2
    return 1
  fi

  # Specification must be software: either a buildable repository or an executable binary.
  # This ensures specifications are unambiguous, complete, and verifiable.

  if [[ -d "$spec_path" ]]; then
    # Repository: check that it contains recognizable source code
    local has_source=false
    while IFS= read -r -d '' _; do
      has_source=true
      break
    done < <(find -L "$spec_path" -maxdepth 3 -type f \( \
      -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" \
      -o -name "*.rs" -o -name "*.java" -o -name "*.c" -o -name "*.cpp" \
      -o -name "*.rb" -o -name "*.sh" -o -name "*.swift" -o -name "*.kt" \
      -o -name "*.cs" -o -name "*.php" -o -name "*.zig" -o -name "*.hs" \
      -o -name "*.ex" -o -name "*.exs" -o -name "*.ml" -o -name "*.scala" \
      -o -name "Makefile" -o -name "Dockerfile" \
    \) -print0 2>/dev/null)

    if [[ "$has_source" != true ]]; then
      echo "[validate] FAILED: specification does not meet format requirements" >&2
      return 1
    fi

    echo "[validate] PASSED"

  elif [[ -f "$spec_path" ]]; then
    # Binary: check that the file contains executable code (ELF, Mach-O, PE, etc.)
    local file_type
    file_type="$(file -b "$spec_path")"

    case "$file_type" in
      *ELF*|*Mach-O*|*PE32*|*executable*|*shared?object*|*byte-compiled*|*Java?archive*)
        ;;
      *)
        echo "[validate] FAILED: specification does not meet format requirements" >&2
        return 1
        ;;
    esac

    echo "[validate] PASSED"

  else
    echo "[validate] FAILED: '$spec_path' is not a directory or regular file" >&2
    return 1
  fi

  echo "[validate] Specification is valid"
}

# --- Core Functions ---

generate() {
  local target="$1"
  local resolved_name
  if [[ -d "$target" ]]; then
    resolved_name="$(cd "$target" && basename "$(pwd)")"
  else
    resolved_name="$(basename "$target")"
  fi
  local timestamp
  timestamp="$(date +%Y%m%d_%H%M%S)"
  local spec_output="$GENERATED_SPECS_DIR/${resolved_name}_${timestamp}"

  mkdir -p "$GENERATED_SPECS_DIR"

  if [[ -d "$target" ]]; then
    echo "[generate] Generating specification from repository: $target"
    echo "[generate] Analyzing source structure..."
    local rsync_opts=(-a --delete)
    # Exclude factory artifacts when generating from our own directory tree
    local resolved_target
    resolved_target="$(cd "$target" && pwd)"
    if [[ "$PERFECT_DIR" == "$resolved_target"/* ]]; then
      rsync_opts+=(--exclude='.perfect/')
    fi
    rsync "${rsync_opts[@]}" "$target/" "$spec_output/"
    echo "[generate] Specification written to: $spec_output"
  elif [[ -f "$target" ]]; then
    echo "[generate] Generating specification from binary: $target"
    echo "[generate] Analyzing binary..."
    cp "$target" "$spec_output"
    echo "[generate] Specification written to: $spec_output"
  else
    echo "Error: '$target' is not a directory or file" >&2
    return 1
  fi

  RESULT="$spec_output"
}

actualize() {
  local spec_path="$1"
  local impl_name
  impl_name="$(basename "$spec_path")"
  local impl_path="$ACTUALIZED_IMPL_DIR/$impl_name"

  validate_spec "$spec_path" || return 1

  mkdir -p "$ACTUALIZED_IMPL_DIR"

  echo "[actualize] Actualizing from spec: $spec_path"

  if [[ -d "$spec_path" ]]; then
    echo "[actualize] Building implementation from specification..."
    rsync -a --delete "$spec_path/" "$impl_path/"
  else
    echo "[actualize] Building implementation from specification..."
    cp "$spec_path" "$impl_path"
  fi

  echo "[actualize] Implementation actualized to: $impl_path"
  RESULT="$impl_path"
}

assess() {
  local impl_path="$1"
  local spec_path="$2"

  if [[ ! -e "$impl_path" ]]; then
    echo "Error: '$impl_path' does not exist" >&2
    return 1
  fi

  echo "[assess] Assessing implementation against specification..."

  local diff_result=0
  local diff_opts=()
  # GNU diff follows directory symlinks by default; --no-dereference prevents
  # infinite recursion on self-referential symlinks (e.g. perfect_spec/perfect -> ..)
  if diff --no-dereference /dev/null /dev/null 2>/dev/null; then
    diff_opts+=(--no-dereference)
  fi
  if [[ -d "$impl_path" ]]; then
    diff -r "${diff_opts[@]}" "$impl_path" "$spec_path" > /dev/null 2>&1 || diff_result=$?
  else
    diff "${diff_opts[@]}" "$impl_path" "$spec_path" > /dev/null 2>&1 || diff_result=$?
  fi

  if [[ "$diff_result" -eq 0 ]]; then
    echo "[assess] PASSED: implementation matches specification exactly"
  else
    echo "[assess] FAILED: implementation diverges from specification" >&2
    return 1
  fi
}

# --- CLI ---

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  validate  <spec_path>    Validate that a specification meets factory requirements
  generate  <target>       Generate a spec from a repository (dir) or binary (file)
  actualize <spec_path>    Actualize an implementation from a specification
  assess    <impl> <spec>  Assess an implementation against its specification
  e2e       <target>       Run the full pipeline: generate -> validate -> actualize -> assess
  version                  Print version information
EOF
}

cmd_validate() {
  [[ $# -lt 1 ]] && { echo "Error: validate requires a spec path argument" >&2; usage; return 1; }
  validate_spec "$1"
}

cmd_generate() {
  [[ $# -lt 1 ]] && { echo "Error: generate requires a target (directory or binary)" >&2; usage; return 1; }
  generate "$1"
}

cmd_actualize() {
  [[ $# -lt 1 ]] && { echo "Error: actualize requires a spec path argument" >&2; usage; return 1; }
  actualize "$1"
}

cmd_assess() {
  [[ $# -lt 2 ]] && { echo "Error: assess requires <implementation> and <spec_path>" >&2; usage; return 1; }
  assess "$1" "$2"
}

cmd_version() {
  local v="$VERSION"
  # If version was not embedded at build time, read from VERSION file
  if [[ "$v" == "@@""VERSION""@@" ]]; then
    local version_file="$SCRIPT_DIR/../VERSION"
    if [[ -f "$version_file" ]]; then
      v="$(cat "$version_file")"
    else
      v="dev"
    fi
  fi
  echo "perfect $v"
}

cmd_e2e() {
  [[ $# -lt 1 ]] && { echo "Error: e2e requires a target (directory or binary)" >&2; usage; return 1; }
  local target="$1"

  echo "=== E2E Pipeline ==="
  echo

  generate "$target"
  local spec_output="$RESULT"
  echo

  actualize "$spec_output"
  local actualized_output="$RESULT"
  echo

  assess "$actualized_output" "$spec_output"
  echo

  echo "=== E2E Complete ==="
}

# --- Entrypoint ---

main() {
  [[ $# -lt 1 ]] && { usage; exit 1; }

  local command="$1"
  shift

  case "$command" in
    validate)   cmd_validate "$@" ;;
    generate)   cmd_generate "$@" ;;
    actualize)  cmd_actualize "$@" ;;
    assess)     cmd_assess "$@" ;;
    e2e)        cmd_e2e "$@" ;;
    version|--version|-v) cmd_version ;;
    -h|--help)  usage ;;
    *)
      echo "Unknown command: $command" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
