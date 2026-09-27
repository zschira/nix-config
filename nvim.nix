
{ config, pkgs, ... }:

{
  # Configure uv with direnv
  # TODO remove when official support for uv is merged
  # See: https://github.com/direnv/direnv/issues/1250
  home.file.".config/direnv/direnvrc" = {
    text = ''
layout_uv() {
  # Reload when project config or lockfile change. With --frozen, a pyproject.toml
  # change triggers an immediate error (lockfile out of sync); a uv.lock change
  # triggers a re-sync after the user has updated it manually.
  watch_file .python-version pyproject.toml uv.lock

  if ! has uv; then
    log_error "uv: command not found. Install from https://docs.astral.sh/uv/"
    return 1
  fi

  if [[ ! -f pyproject.toml ]]; then
    log_error "uv: no pyproject.toml found. Run \`uv init\` to create a project."
    return 1
  fi

  local venv_path
  venv_path="$(expand_path "''${UV_PROJECT_ENVIRONMENT:-.venv}")"
  export UV_PROJECT_ENVIRONMENT="$venv_path"

  local python_arg=()
  local sync_args=()
  # uv python specifiers (versions, paths, implementations) never start with
  # "--", so this distinguishes a python specifier from arguments intended for `uv sync`.
  if [[ -n "''${1:-}" && "''${1:-}" != --* ]]; then
    python_arg=(--python "$1")
    sync_args=("''${@:2}")
  else
    sync_args=("$@")
  fi

  # must use --frozen: we don't want to modify the lock file
  uv sync --frozen "''${python_arg[@]}" "''${sync_args[@]}"

  export VIRTUAL_ENV="$venv_path"
  if [[ -d "$venv_path/bin" ]]; then
    PATH_add "$venv_path/bin"
  fi
  if [[ -d "$venv_path/Scripts" ]]; then
    PATH_add "$venv_path/Scripts"
  fi
}
'';
  };

  programs.neovim = {
    enable = true;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; let
      codecompanion-nvim-pinned = pkgs.vimUtils.buildVimPlugin {
        pname = "codecompanion-nvim";
        version = "19.23.0";

        src = pkgs.fetchFromGitHub {
          owner = "olimorris";
          repo = "codecompanion.nvim";

          # Replace this with the latest release tag from:
          # https://github.com/olimorris/codecompanion.nvim/releases
          rev = "v19.23.0";

          # First use:
          # nix build
          #
          # Nix will tell you the correct hash to put here.
          hash = "sha256-Qwp5GMiThljD7l9ygl8T333OlBQ2Me1k6/KWAkFq4QU=";
        };

        dependencies = [
          plenary-nvim
        ];
        doCheck = false;
      };
    in [

      {
        plugin = gruvbox;
        type = "lua";
        config = ''
          vim.cmd.colorscheme("gruvbox")
        '';
      }

      {
        plugin = neo-tree-nvim;
        type = "lua";
        config = ''
          require("neo-tree").setup({
            filesystem = {
              filtered_items = {
                hide_dotfiles = false,
              },
            },
          })
        '';
      }

      {
        plugin = bufferline-nvim;
        type = "lua";
        config = ''
          vim.opt.termguicolors = true
          require("bufferline").setup{}
        '';
      }

      plenary-nvim
      nui-nvim
      {
        plugin = codecompanion-nvim-pinned;
        type = "lua";
        config = ''
          require("codecompanion").setup({
            adapters = {
              http = {
                openrouter = function()
                  return require("codecompanion.adapters").extend("openrouter", {
                    schema = {
                      preset = { default = "@preset/nvim-coding" },
                    },
                  })
                end,
              },
            },
            interactions = {
              chat = {
                adapter = {
                  name = "openrouter",
                  model = "openai/gpt-5.4-mini",
                },
              },

              inline = {
                adapter = {
                  name = "openrouter",
                  model = "openai/gpt-5.4-mini",
                },
              },
            },
          })
        '';
      }
      nvim-surround

      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require("lualine").setup({
            options = {
              theme = "gruvbox",
              globalstatus = true,
            },
          })
        '';
      }

      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = ''
          require("gitsigns").setup()
        '';
      }

      vim-fugitive

      (nvim-treesitter.withPlugins (p: with p; [
        python
        lua
        nix
        bash
        json
        yaml
        markdown
      ]))

      {
        plugin = blink-cmp;
        type = "lua";
        config = ''
          require("blink.cmp").setup({
            keymap = {
              preset = "cmdline",
            },

            completion = {
              documentation = {
                auto_show = true,
              },
            },

            signature = {
              enabled = true,
            },
          });
        '';
      }

      {
        plugin = conform-nvim;
        type = "lua";
        config = ''
          require("conform").setup({
            formatters_by_ft = {
              python = {
                "ruff_format",
                "ruff_organize_imports",
              },
              nix = {
                "nixfmt",
              },
              lua = {
                "stylua",
              },
            },

            format_on_save = {
              timeout_ms = 1000,
              lsp_fallback = true,
            },
          })

          vim.keymap.set(
            { "n", "v" },
            "<leader>f",
            function()
              require("conform").format({
                async = true,
                lsp_fallback = true,
              })
            end,
            { desc = "Format buffer" }
          )
        '';
      }

      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''
          local capabilities =
            require("blink.cmp").get_lsp_capabilities()

          vim.lsp.config("pyright", {
            capabilities = capabilities,
          })

          vim.lsp.enable("pyright")
        '';
      }
    ];

    initLua = ''
      --------------------------------------------------
      -- General options
      --------------------------------------------------

      vim.g.mapleader = ","

      vim.opt.number = true
      vim.opt.mouse = "a"

      vim.opt.expandtab = true
      vim.opt.shiftwidth = 4
      vim.opt.tabstop = 4

      vim.opt.clipboard = "unnamedplus"

      vim.opt.completeopt = {
        "menu",
        "menuone",
        "noselect",
      }


      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })


      --------------------------------------------------
      -- Keymaps
      --------------------------------------------------

      -- File tree
      vim.keymap.set(
        "n",
        "<leader>e",
        "<cmd>Neotree toggle<CR>",
        { desc = "File explorer" }
      )


      -- Buffer navigation
      vim.keymap.set(
        "n",
        "<Tab>",
        ":bnext<CR>",
        { silent = true }
      )

      vim.keymap.set(
        "n",
        "<S-Tab>",
        ":bprevious<CR>",
        { silent = true }
      )


      -- Clipboard
      vim.keymap.set(
        { "n", "v" },
        "<leader>y",
        '"+y'
      )

      vim.keymap.set(
        "n",
        "<leader>p",
        '"+p'
      )

      -- code companion
      vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
      vim.keymap.set({ "n", "v" }, "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
      vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

      -- Expand 'cc' into 'CodeCompanion' in the command line
      vim.cmd([[cab cc CodeCompanion]])

      -- Expand 'gs' into 'GitSigns' in the command line
      vim.cmd([[cab gs Gitsigns]])


      --------------------------------------------------
      -- UI
      --------------------------------------------------

      vim.opt.termguicolors = true


      --------------------------------------------------
      -- Diagnostics
      --------------------------------------------------

      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
      })
    '';
  };
}
