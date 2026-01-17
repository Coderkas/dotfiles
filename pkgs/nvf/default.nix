{
  lib,
  nil_git,
  pkgs,
  ...
}:
let
  customOls = pkgs.ols.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.git ];
    installPhase = old.installPhase + /* sh */ ''
      cp -r builtin $out/bin/
    '';
  });
in
{
  vim = {
    enableLuaLoader = true;
    extraPackages = [
      pkgs.clippy
    ];
    lazy.plugins = {
      telescope.event = "VimEnter";
      vimtex = {
        package = pkgs.vimPlugins.vimtex;
        before = /* lua */ ''
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
        callback = lib.generators.mkLuaInline /* lua */ "function() vim.hl.on_yank() end";
      }
      {
        event = [
          "CmdlineEnter"
          "CmdlineLeave"
        ];
        group = "MyUtils";
        desc = "Only highlight while searching";
        callback = lib.generators.mkLuaInline /* lua */ ''
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
        callback = lib.generators.mkLuaInline /* lua */ ''
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
    ];
    luaConfigPost = /* lua */ ''
      vim.api.nvim_create_user_command('LspInfo', ':checkhealth vim.lsp', {desc = 'Show vim.lsp health'})
      vim.api.nvim_create_user_command('LspLog', function()
        vim.cmd(string.format('tabnew %s', vim.lsp.log.get_filename()))
      end, {desc = 'Show LSP log'})

      vim.lsp.log.set_level('ERROR')
    '';
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
      winborder = "rounded";
    };
    searchCase = "smart";
    syntaxHighlighting = true;
    undoFile.enable = true;
    diagnostics.enable = true;
    ui.borders.enable = true;
    bell = "visual";

    keymaps = [
      {
        key = "<leader>fk";
        mode = "n";
        action = /* lua */ ''require("telescope.builtin").keymaps'';
        desc = "Keymaps [Telescope]";
        lua = true;
      }
      {
        key = "<leader>fm";
        mode = "n";
        action = /* lua */ ''
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
        action = /* lua */ ''
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
        action = /* lua */ ''require("telescope.builtin").quickfix'';
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
      nvim-web-devicons.enable = true;
      fidget-nvim.enable = true;
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
        "<leader>lw" = "+Workspace";
        "<leader>fv" = null;
        "<leader>h" = null;
        "<leader>g" = "+Git";
      };
    };
    comments.comment-nvim.enable = true;
    formatter.conform-nvim = {
      enable = true;
      setupOpts = {
        formatters_by_ft = {
          c = lib.generators.mkLuaInline /* lua */ ''{"clang-format",lsp_format = "fallback"}'';
          cpp = lib.generators.mkLuaInline /* lua */ ''{"clang-format",lsp_format = "fallback"}'';
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

    lsp = {
      enable = true;
      formatOnSave = true;
      mappings = {
        hover = "K";
        signatureHelp = "<leader>lS";
        openDiagnosticFloat = "<leader>e";
        nextDiagnostic = "<leader>dn";
        previousDiagnostic = "<leader>dp";
        format = "<leader>lf";
        toggleFormatOnSave = null;
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
      servers = {
        ols = {
          enable = true;
          cmd = [ (lib.meta.getExe customOls) ];
          filetypes = [ "odin" ];
          settings = {
            enable_inlay_hints_params = true;
            enable_inlay_hints_default_params = true;
            enable_inlay_hints_implicit_return = true;
            enable_semantic_tokens = true;
            enable_snippets = true;
            enable_auto_import = true;
            checker_args = "-strict-style";
          };
          root_dir = lib.generators.mkLuaInline /* lua */ ''
            function(bufnr, on_dir)
              local fname = vim.api.nvim_buf_get_name(bufnr)
              on_dir(util.root_pattern('ols.json', '.git', '*.odin')(fname))
            end
          '';
        };
        nil = {
          enable = true;
          cmd = [ "${nil_git}/bin/nil" ];
          settings = {
            nil = {
              nix = {
                binary = "${pkgs.nixVersions.nix_2_30}/bin/nix";
                maxMemoryMB = 4096;
                flake = {
                  autoArchive = true;
                  nixpkgsInputName = "nixpkgs";
                };
              };
            };
          };
          filetypes = [ "nix" ];
          root_markers = [
            ".git"
            "flake.nix"
          ];
        };
        nixd = {
          enable = true;
          cmd = [ "${lib.getExe pkgs.nixd}" ];
          settings = {
            nixd = {
              nixpkgs = {
                expr = "import (builtins.getFlake \"/home/lorkas/dotfiles\").inputs.nixpkgs { }";
              };
              options = {
                nvf.expr = "((builtins.getFlake \"/home/lorkas/dotfiles\").inputs.nvf.lib.neovimConfiguration { pkgs = (import <nixpkgs> ); }).options";
                nixos.expr = "(builtins.getFlake \"/home/lorkas/dotfiles\").nixosConfigurations.omnissiah.options";
              };
            };
          };
          filetypes = [ "nix" ];
          root_markers = [
            ".git"
            "flake.nix"
          ];
        };
      };
    };
    languages = {
      enableExtraDiagnostics = true;
      enableFormat = true;
      enableTreesitter = true;
      assembly.enable = true;
      bash.enable = true;
      clang = {
        enable = true;
        cHeader = true;
      };
      css.enable = true;
      go.enable = true;
      html.enable = true;
      lua.enable = true;
      markdown = {
        enable = true;
        extensions.markview-nvim = {
          enable = true;
          setupOpts = {
            preview = {
              enable = false;
              icon_provider = "devicons";
              callbacks.on_attach = lib.generators.mkLuaInline /* lua */ ''
                function(bufnr, _)
                  vim.keymap.set("n", "<leader>lp", "<CMD>Markview splitToggle<CR>", {desc = "Toggle Markview split", noremap = true, silent = true, buffer = bufnr})
                  end
              '';
            };
            experimental = {
              prefer_nvim = true;
              file_open_command = "tabnew";
            };
            latex.enable = true;
            markdown.enable = true;
            typst.enable = true;
          };
        };
      };
      nix = {
        enable = true;
        lsp.enable = false;
        format.type = [ "nixfmt" ];
      };
      odin = {
        enable = true;
        lsp.enable = false;
      };
      python.enable = true;
      qml.enable = true;
      rust = {
        enable = true;
        lsp.opts = /* lua */ ''
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
        extensions.crates-nvim.enable = false;
      };
      ts = {
        enable = true;
        extensions.ts-error-translator.enable = true;
        lsp.servers = [
          "denols"
          "ts_ls"
        ];
      };
      yaml.enable = true;
      zig.enable = true;
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
          setup.ui-select = lib.generators.mkLuaInline /* lua */ ''{require("telescope.themes").get_dropdown(),},'';
        }
      ];
      mappings = {
        gitBranches = null;
        gitBufferCommits = "<leader>gBc";
        gitCommits = "<leader>gc";
        gitStatus = "<leader>gs";
        gitStash = "<leader>gS";
        lspDefinitions = "<leader>ld";
        lspDocumentSymbols = "<leader>ls";
        lspImplementations = "<leader>li";
        lspReferences = "<leader>lr";
        lspTypeDefinitions = "<leader>lt";
        lspWorkspaceSymbols = "<leader>lws";
        helpTags = null;
        diagnostics = "<leader>dl";
      };
      setupOpts.defaults = {
        color_devicons = true;
        layout_config.horizontal.prompt_position = "bottom";
        sorting_strategy = "descending";
        selection_caret = " >";
      };
    };

    treesitter = {
      enable = true;
      fold = true;
      autotagHtml = true;
      grammars = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
        cmake
        desktop
        fish
        http
        hyprlang
        ini
        json
        #jsonc
        kitty
        query
        rasi
        regex
        ron
        scss
        ssh_config
        toml
        xml
        zathurarc
      ];
    };
  };
}
