zo() {
  local pdf
  pdf=$(find "${1:-.}" -name "*.pdf" -type f 2>/dev/null | fzf --preview 'file {}')
  [[ -n "$pdf" ]] && zathura "$pdf" &
}
