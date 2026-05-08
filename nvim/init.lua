-- =====================
-- 基本設定
-- =====================

-- leader キーを Space に設定
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- 行番号を表示
vim.opt.number = true

-- 相対行番号を表示
vim.opt.relativenumber = true

-- タブをスペース2つに
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- 検索設定
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- カーソルラインをハイライト
vim.opt.cursorline = true

-- クリップボードをシステムと共有
vim.opt.clipboard = 'unnamedplus'

-- 画面の左に余白を追加
vim.opt.signcolumn = 'yes'

-- True Color を有効化
vim.opt.termguicolors = true

-- ファイルの外部変更を自動検知・再読み込み
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  command = 'checktime',
})

-- =====================
-- lazy.nvim の設定
-- =====================

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- プラグインの設定
require('lazy').setup({

    -- カラーテーマ
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      require('tokyonight').setup({
        transparent = true,
        styles = {
          sidebars = 'transparent',
          floats = 'transparent',
        },
      })
      vim.cmd('colorscheme tokyonight-night')
    end,
  },

    -- ステータスライン
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = {
          theme = 'tokyonight',
        },
      })
    end,
  },

  -- ファジーファインダー
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')

      -- キーマップ設定
      vim.keymap.set('n', '<leader>ff', builtin.find_files)  -- ファイル検索
      vim.keymap.set('n', '<leader>fg', builtin.live_grep)   -- 全体検索
      vim.keymap.set('n', '<leader>fb', builtin.buffers)     -- バッファ一覧
    end,
  },

  -- ファイルツリー
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('neo-tree').setup({
        window = {
          width = 30,
          mappings = {
            ['y'] = false,
            ['<bs>'] = false,
          },
        },
        filesystem = {
          commands = {
            copy_path = function(state)
              local node = state.tree:get_node()
              vim.fn.setreg('+', node.path)
              vim.notify('Copied: ' .. node.path)
            end,
            copy_name = function(state)
              local node = state.tree:get_node()
              vim.fn.setreg('+', node.name)
              vim.notify('Copied: ' .. node.name)
            end,
            copy_dir = function(state)
              local node = state.tree:get_node()
              local path = node.type == 'directory' and node.path
                or vim.fn.fnamemodify(node.path, ':h')
              vim.fn.setreg('+', path)
              vim.notify('Copied: ' .. path)
            end,
          },
          window = {
            mappings = {
              ['y'] = false,
              ['yp'] = 'copy_path',
              ['yf'] = 'copy_name',
              ['yd'] = 'copy_dir',
            },
          },
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          use_libuv_file_watcher = true,
        },
     })

      -- キーマップ設定
      vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>')
    end,
  },

  -- LSP 管理
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },

  -- LSP 設定
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
    },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = {
          'lua_ls',      -- Lua
          'ts_ls',       -- TypeScript / JavaScript
          'eslint',      -- ESLint
          'tailwindcss', -- Tailwind CSS
          'cssls',       -- CSS
          'html',        -- HTML
          'gopls',       -- Go
        },
      })

      local lspconfig = require('lspconfig')

      -- 各 LSP サーバーを起動
      lspconfig.lua_ls.setup({})
      lspconfig.ts_ls.setup({})
      lspconfig.eslint.setup({})
      lspconfig.tailwindcss.setup({})
      lspconfig.cssls.setup({})
      lspconfig.html.setup({})
      lspconfig.gopls.setup({})

      -- キーマップ設定（LSP が起動しているバッファのみ有効）
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)       -- 定義へジャンプ
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)             -- ドキュメント表示
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)   -- リネーム
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts) -- コードアクション
        end,
      })
    end,
  },

  -- 補完
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),  -- 補完を手動で起動
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- 候補を確定
          ['<C-j>'] = cmp.mapping.select_next_item(), -- 次の候補
          ['<C-k>'] = cmp.mapping.select_prev_item(), -- 前の候補
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end,
  },

  -- Git 連携
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        on_attach = function(bufnr)
          local gs = require('gitsigns')
          local opts = { buffer = bufnr }

          -- ハンク操作
          vim.keymap.set('n', ']c', gs.next_hunk, opts)   -- 次の変更箇所へ
          vim.keymap.set('n', '[c', gs.prev_hunk, opts)   -- 前の変更箇所へ
          vim.keymap.set('n', '<leader>hs', gs.stage_hunk, opts)   -- ハンクをステージ
          vim.keymap.set('n', '<leader>hr', gs.reset_hunk, opts)   -- ハンクをリセット
          vim.keymap.set('n', '<leader>hp', gs.preview_hunk, opts) -- ハンクをプレビュー
          vim.keymap.set('n', '<leader>hb', gs.blame_line, opts)   -- 行の blame を表示
        end,
      })
    end,
  },

  -- キーマップ可視化
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      local wk = require('which-key')
      wk.setup()

      -- キーマップにグループ名をつける
      wk.add({
        { '<leader>f', group = 'find' },
        { '<leader>h', group = 'Hunk' },
        { '<leader>r', group = 'Rename' },
        { '<leader>c', group = 'Code' },
        { '<leader>e', desc = 'Explorer' },
      })
    end,
  },

})


