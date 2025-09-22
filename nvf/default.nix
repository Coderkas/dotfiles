{
  pkgs,
  myInputs,
  lib,
  system,
  ...
}:
{
  vim = {
    enableLuaLoader = true;
    extraPackages = [
      pkgs.manix
      pkgs.clippy
    ];
    lazy.plugins = {
      telescope.event = "VimEnter";
      vimtex = {
        package = pkgs.vimPlugins.vimtex;
        before = ''
          vim.g.vimtex_view_method = 'zathura_simple'
          vim.g.vimtex_compiler_method = 'tectonic'
        '';
        ft = "tex";
      };
    };

    augroups = [ { name = "MyUtils"; } ];
    autocmds = [
      {
        event = [ "TextYankPost" ];
        group = "MyUtils";
        desc = "Highlight when yanking (copying) text";
        callback = lib.generators.mkLuaInline "function() vim.hl.on_yank() end";
      }
      {
        event = [
          "CmdlineEnter"
          "CmdlineLeave"
        ];
        group = "MyUtils";
        desc = "Only highlight while searching";
        callback = lib.generators.mkLuaInline ''
          function()
            local curr = vim.o.hlsearch
            vim.o.hlsearch = not curr
          end
        '';
      }
      {
        event = [ "LspAttach" ];
        group = "MyUtils";
        desc = "Highlighting of same document symbols after some delay";
        callback = lib.generators.mkLuaInline ''
          function(args)
            local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

            if client:supports_method 'textDocument/documentHighlight' then
              local highlight_augroup = vim.api.nvim_create_augroup('MyHighlighting', { clear = false })
              vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = args.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
              })

              vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = args.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
              })

              vim.api.nvim_create_autocmd('LspDetach', {
                group = vim.api.nvim_create_augroup('MyDetach', { clear = true }),
                callback = function(args2)
                  vim.lsp.buf.clear_references()
                  vim.api.nvim_clear_autocmds { group = 'MyHighlighting', buffer = args2.buf }
                end,
              })
            end
          end
        '';
      }
      {
        event = [ "LspAttach" ];
        group = "MyUtils";
        desc = "Additional rust keymaps";
        callback = lib.generators.mkLuaInline ''
          function(args)
            local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

            if client.name == 'rust-analyzer' then
              vim.keymap.set('n', '<localleader>rd', function()
                vim.cmd.RustLsp({ 'renderDiagnostic', 'current' })
              end, { desc = 'RustLsp diagnostics' })

              vim.keymap.set('n', '<localleader>re', function()
                vim.cmd.RustLsp({ 'explainError', 'current' })
              end, { desc = 'RustLsp explain errors' })
            end
          end
        '';
      }
    ];
    hideSearchHighlight = true;
    clipboard = {
      enable = true;
      providers.wl-copy = {
        enable = true;
        package = pkgs.wl-clipboard;
      };
      registers = "unnamedplus";
    };
    options = {
      breakindent = false;
      showmode = true;
      tm = 300;
      updatetime = 250;
      wrap = false;
      splitright = true;
      splitbelow = true;
      list = true;
      listchars = "tab:» ,trail:·,nbsp:␣";
      inccommand = "split";
      cursorline = true;
      scrolloff = 10;
    };
    searchCase = "smart";
    syntaxHighlighting = true;
    undoFile.enable = true;
    diagnostics.enable = true;
    ui.borders.enable = true;
    bell = "visual";

    keymaps = [
      {
        key = "<leader>pv";
        mode = "n";
        action = "<cmd>:Ex<CR>";
        desc = "Open folder in Netrw";
      }
      {
        key = "<leader>fk";
        mode = "n";
        action = ''require("telescope.builtin").keymaps'';
        desc = "Keymaps [Telescope]";
        lua = true;
      }
      {
        key = "<leader>fn";
        mode = "n";
        action = ''require("telescope-manix").search'';
        desc = "Manix [Telescope]";
        lua = true;
      }
      {
        key = "<leader>fm";
        mode = "n";
        action = ''
            function()
              require("telescope.builtin").man_pages {
                sections = { 'ALL' };
                attach_mappings = function(prompt_bufnr)
                  local action_set = require 'telescope.actions.set'
                  local action_state = require 'telescope.actions.state'
                  local actions = require 'telescope.actions'
                  local utils = require 'telescope.utils'
                  action_set.select:replace(function(_, cmd)
                    local selection = action_state.get_selected_entry()
                    if selection == nil then
                      utils.__warn_no_selection 'builtin.man_pages'
                      return
                    end

                    local args = selection.section .. ' ' .. selection.value
                    actions.close(prompt_bufnr)
                    if cmd == 'default' then
                      vim.cmd('hide Man ' .. args)
                    elseif cmd == 'vertical' then
                      local curr_win_width = vim.api.nvim_win_get_width(0) / 2 - 5
                      vim.cmd(':let $MANWIDTH=' .. curr_win_width .. ' | :vert Man ' .. args)
                    elseif cmd == 'horizontal' then
                      vim.cmd('Man ' .. args)
                    elseif cmd == 'tab' then
                      vim.cmd('tab Man ' .. args)
                    end
                  end)

                  return true
                end
              }
          end
        '';
        desc = "Man pages [Telescope]";
        lua = true;
      }
      {
        key = "<leader>fh";
        mode = "n";
        action = ''
            function()
              require("telescope.builtin").help_tags {
                attach_mappings = function(prompt_bufnr)
                  local action_set = require 'telescope.actions.set'
                  local action_state = require 'telescope.actions.state'
                  local actions = require 'telescope.actions'
                  local utils = require 'telescope.utils'
                  action_set.select:replace(function(_, cmd)
                    local selection = action_state.get_selected_entry()
                    if selection == nil then
                      utils.__warn_no_selection 'builtin.help_tags'
                      return
                    end

                    actions.close(prompt_bufnr)
                    if cmd == 'default' then
                      local curr_buf_id = vim.api.nvim_get_current_buf()
                      vim.cmd('help ' .. selection.value .. ' |:' .. curr_buf_id .. 'hide')
                    elseif cmd == 'vertical' then
                      vim.cmd('vert help ' .. selection.value)
                    elseif cmd == 'horizontal' then
                      vim.cmd('help ' .. selection.value)
                    elseif cmd == 'tab' then
                      vim.cmd('tab help ' .. selection.value)
                    end
                  end)

                  return true
                end
              }
          end
        '';
        desc = "Help tags [Telescope]";
        lua = true;
      }
      {
        key = "<leader>q";
        mode = "n";
        action = ''require("telescope.builtin").quickfix'';
        desc = "Quickfixes [Telescope]";
        lua = true;
      }
    ];

    theme = {
      enable = true;
      name = "gruvbox";
      style = "dark";
    };

    utility.sleuth.enable = true;

    visuals = {
      cellular-automaton = {
        enable = true;
        mappings.makeItRain = "<leader>gg";
      };
      nvim-web-devicons.enable = true;
    };

    autocomplete.blink-cmp = {
      enable = true;
      friendly-snippets.enable = true;
      setupOpts = {
        completion = {
          keyword.range = "full";
          ghost_text.enabled = true;
          list.selection = {
            preselect = false;
            auto_insert = false;
          };
        };
        snippets.preset = "luasnip";
        signature.enabled = true;
        keymap.preset = "default";
        cmdline.keymap.preset = "default";
      };
      sourcePlugins.ripgrep.enable = true;
    };

    snippets.luasnip.enable = true;
    binds.whichKey = {
      enable = true;
      register = {
        "<leader>fl" = null;
        "<leader>fm" = null;
        "<leader>d" = "+Diagnostics";
        "<leader>l" = "+Lsp";
        "<leader>lf" = "+Format";
        "<leader>lw" = "+Workspace";
      };
    };
    comments.comment-nvim.enable = true;
    formatter.conform-nvim = {
      enable = true;
      setupOpts = {
        formatters_by_ft = {
          c = lib.generators.mkLuaInline ''{"clang-format",lsp_format = "fallback"}'';
          cpp = lib.generators.mkLuaInline ''{"clang-format",lsp_format = "fallback"}'';
          odin = [ "odinfmt" ];
        };
        formatters = {
          odinfmt = {
            command = "odinfmt";
            args = [ "-stdin" ];
            stdin = true;
          };
        };
      };
    };
    git.gitsigns = {
      enable = true;
      mappings = {
        toggleBlame = "<leader>gb";
        toggleDeleted = "<leader>gt";
      };
    };

    lsp = {
      enable = true;
      formatOnSave = true;
      mappings = {
        hover = "K";
        signatureHelp = "<leader>lS";
        openDiagnosticFloat = "<leader>e";
        nextDiagnostic = "<leader>dn";
        previousDiagnostic = "<leader>dp";
        format = "<leader>lfb";
        toggleFormatOnSave = "<leader>lft";
        documentHighlight = null;
        goToDeclaration = null;
        goToDefinition = null;
        goToType = null;
        listDocumentSymbols = null;
        listImplementations = null;
        listReferences = null;
        listWorkspaceSymbols = null;
      };
      otter-nvim.enable = true;
    };
    languages = {
      enableExtraDiagnostics = true;
      enableFormat = true;
      enableTreesitter = true;
      bash.enable = true;
      clang = {
        enable = true;
        cHeader = true;
      };
      css.enable = true;
      go.enable = true;
      html.enable = true;
      lua.enable = true;
      markdown.enable = true;
      nix = {
        enable = true;
        lsp.package = myInputs.nil.packages.${system}.default;
        format = {
          package = pkgs.nixfmt-rfc-style;
          type = "nixfmt";
        };
      };
      odin.enable = true;
      python.enable = true;
      rust = {
        enable = true;
        lsp.opts = ''
          ['rust-analyzer'] = {
            cargo = {
              allFeature = true,
            },
            check = {
              command = 'clippy',
              extraArgs = {
                '--',
                '-Wclippy::pedantic',
                '-Wclippy::nursery',
                '-Aclippy::too-many-lines',
              },
            },
            procMacro = {
              enable = true,
            },
          }
        '';
      };
      ts = {
        enable = true;
        extensions.ts-error-translator.enable = true;
      };
    };

    mini = {
      ai.enable = true;
      splitjoin.enable = true;
      surround.enable = true;
    };

    telescope = {
      enable = true;
      extensions = [
        {
          name = "fzf";
          packages = [ pkgs.vimPlugins.telescope-fzf-native-nvim ];
          setup.fzf = {
            fuzzy = true;
            override_generic_sorter = true;
            override_file_sorter = true;
            case_mode = "smart_case";
          };
        }
        {
          name = "ui-select";
          packages = [ pkgs.vimPlugins.telescope-ui-select-nvim ];
          setup.ui-select = lib.generators.mkLuaInline ''{require("telescope.themes").get_dropdown(),},'';
        }
        {
          name = "manix";
          packages = [ pkgs.vimPlugins.telescope-manix ];
          setup.manix = {
            manix_args = [
              "--source"
              "hm_options"
              "--source"
              "nixos_options"
              "--source"
              "nixpkgs_tree"
            ];
            cword = false;
          };
        }
      ];
      mappings = {
        diagnostics = "<leader>dl";
        gitBranches = "<leader>fvg";
        gitBufferCommits = "<leader>fvb";
        gitCommits = "<leader>fvc";
        gitStatus = "<leader>fvs";
        lspDefinitions = "<leader>ld";
        lspDocumentSymbols = "<leader>ls";
        lspImplementations = "<leader>li";
        lspReferences = "<leader>lr";
        lspTypeDefinitions = "<leader>lt";
        lspWorkspaceSymbols = "<leader>lws";
        helpTags = null;
      };
      setupOpts.defaults = {
        color_devicons = true;
        layout_config.horizontal.prompt_position = "bottom";
        sorting_strategy = "descending";
        selection_caret = " >";
      };
    };

    treesitter.textobjects.enable = true;
  };
}
