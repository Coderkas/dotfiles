return {
  cmd = { 'nil' },
  filetypes = { 'nix' },
  root_markers = {
    'flake.nix',
    '.git',
  },
  settings = {
    Nil = {
      formatting = {
        command = { 'nixfmt' },
      },
    },
  },
}
