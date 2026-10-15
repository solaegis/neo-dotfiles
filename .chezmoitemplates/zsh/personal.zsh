# =============================================================================
# Personal-context extras (optional hooks).
# =============================================================================

# Route `cursor <path>` under org git roots to the matching UDSW userdata.
# Bare `cursor` / other paths keep the stock Cursor CLI (Personal).
cursor() {
  local -a passthrough=()
  local arg resolved
  local acxiom_root="${HOME}/git/acxiom"
  local omnicom_root="${HOME}/git/omnicom"
  local profile=""

  for arg in "$@"; do
    case "${arg}" in
      -*)
        passthrough+=("${arg}")
        ;;
      -)
        passthrough+=("${arg}")
        ;;
      *)
        if [[ "${arg}" == /* ]]; then
          resolved="${arg}"
        elif [[ "${arg}" == "~"* ]]; then
          resolved="${arg/#\~/${HOME}}"
        else
          resolved="${PWD}/${arg}"
        fi
        if [[ -e "${resolved}" ]]; then
          resolved="$(realpath "${resolved}")"
        fi
        if [[ -z "${profile}" ]]; then
          if [[ "${resolved}" == "${acxiom_root}" || "${resolved}" == "${acxiom_root}/"* ]]; then
            profile=acxiom
          elif [[ "${resolved}" == "${omnicom_root}" || "${resolved}" == "${omnicom_root}/"* ]]; then
            profile=omnicom
          fi
        fi
        passthrough+=("${arg}")
        ;;
    esac
  done

  case "${profile}" in
    acxiom)
      if command -v cursor-acxiom >/dev/null 2>&1; then
        command cursor-acxiom "${passthrough[@]}"
      else
        command cursor \
          --user-data-dir "${HOME}/Library/Application Support/udsw/cursor/u/acxiom" \
          --extensions-dir "${HOME}/.cursor/extensions" \
          "${passthrough[@]}"
      fi
      ;;
    omnicom)
      if command -v cursor-omnicom >/dev/null 2>&1; then
        command cursor-omnicom "${passthrough[@]}"
      else
        command cursor \
          --user-data-dir "${HOME}/Library/Application Support/udsw/cursor/u/omnicom" \
          --extensions-dir "${HOME}/.cursor/extensions" \
          "${passthrough[@]}"
      fi
      ;;
    *)
      command cursor "$@"
      ;;
  esac
}
