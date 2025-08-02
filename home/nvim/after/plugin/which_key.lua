local wk = require 'which-key'
wk.add {
  {
    '<leader>?',
    function()
      wk.show { global = false }
    end,
    desc = 'Buffer Local Keymaps',
  },
  {
    '<leader>??',
    function()
      wk.show { global = true }
    end,
    desc = 'Global Keymaps',
  },
}
