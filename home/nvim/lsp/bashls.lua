return {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'bash', 'sh' },
  root_markers = {
    '.git',
  },
  settings = {
    bashIde = {
      globalPattern = '*@(.sh|.inc|.bash|.command)',
    },
  },
}
