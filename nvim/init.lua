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
      vim.keymap.set('n', '<leader>fh', function()
        builtin.find_files({ hidden = true })
      end)                                                    -- 隠しファイル含む検索
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
          width = 40,
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

  -- LSP・フォーマッター・Linter の自動インストール
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-tool-installer').setup({
        ensure_installed = {
          -- LSP
          'lua-language-server',
          'typescript-language-server',
          'eslint-lsp',
          'tailwindcss-language-server',
          'css-lsp',
          'html-lsp',
          'gopls',
          -- フォーマッター
          'prettier',
          'stylua',
          'gofumpt',
        },
        auto_update = false,
        run_on_start = true,
      })
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
      -- Neovim 0.11 の新 API でサーバー固有の設定を行う
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file('', true),
            },
            diagnostics = { globals = { 'vim' } },
          },
        },
      })

      -- mason-lspconfig はインストール済みサーバーを自動で vim.lsp.enable() する
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

      -- キーマップ設定（LSP が起動しているバッファのみ有効）
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },

  -- シンタックスハイライト・コード解析基盤
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'lua', 'typescript', 'javascript', 'tsx', 'html', 'css', 'go',
          'json', 'yaml', 'markdown', 'bash', 'dockerfile',
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- HTMLタグの自動補完・リネーム（Auto Close Tag / Auto Rename Tag 相当）
  {
    'windwp/nvim-ts-autotag',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('nvim-ts-autotag').setup()
    end,
  },

  -- 括弧・引用符の自動補完
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup()
    end,
  },

  -- コードフォーマット（Prettier 相当）
  {
    'stevearc/conform.nvim',
    config = function()
      require('conform').setup({
        formatters_by_ft = {
          lua = { 'stylua' },
          javascript = { 'prettier' },
          typescript = { 'prettier' },
          javascriptreact = { 'prettier' },
          typescriptreact = { 'prettier' },
          css = { 'prettier' },
          html = { 'prettier' },
          json = { 'prettier' },
          yaml = { 'prettier' },
          markdown = { 'prettier' },
          go = { 'gofmt' },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
    end,
  },

  -- コメントアウト操作（gcc / gc + モーション）
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end,
  },

  -- インデントガイド線
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    config = function()
      require('ibl').setup()
    end,
  },

  -- LSP診断の一覧表示（Error Lens 相当）
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('trouble').setup()
      vim.keymap.set('n', '<leader>xx', ':Trouble diagnostics toggle<CR>', { desc = 'Diagnostics' })
      vim.keymap.set('n', '<leader>xd', ':Trouble diagnostics toggle filter.buf=0<CR>', { desc = 'Buffer Diagnostics' })
    end,
  },

  -- Git差分・履歴表示（Git Graph / GitLens 相当）
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      vim.keymap.set('n', '<leader>gd', ':DiffviewOpen<CR>', { desc = 'Git Diff' })
      vim.keymap.set('n', '<leader>gh', ':DiffviewFileHistory %<CR>', { desc = 'Git File History' })
      vim.keymap.set('n', '<leader>gc', ':DiffviewClose<CR>', { desc = 'Git Diff Close' })
    end,
  },

  -- スニペットエンジン
  {
    'L3MON4D3/LuaSnip',
    dependencies = { 'saadparwaiz1/cmp_luasnip' },
  },

  -- 補完
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'saadparwaiz1/cmp_luasnip',
      'L3MON4D3/LuaSnip',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      -- nvim-autopairs との連携
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),  -- 補完を手動で起動
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- 候補を確定
          ['<C-j>'] = cmp.mapping.select_next_item(), -- 次の候補
          ['<C-k>'] = cmp.mapping.select_prev_item(), -- 前の候補
          ['<Tab>'] = cmp.mapping(function(fallback)
            if luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
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

  -- スタートダッシュボード
  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local alpha = require('alpha')
      local dashboard = require('alpha.themes.dashboard')

      dashboard.section.header.val = {
        '                                                     ',
        '  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ',
        '  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ',
        '  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ',
        '  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ',
        '  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ',
        '  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ',
        '                                                     ',
      }

      dashboard.section.buttons.val = {
        dashboard.button('f', '  Find file',     ':Telescope find_files<CR>'),
        dashboard.button('g', '  Live grep',     ':Telescope live_grep<CR>'),
        dashboard.button('r', '  Recent files',  ':Telescope oldfiles<CR>'),
        dashboard.button('n', '  New file',      ':enew<CR>'),
        dashboard.button('e', '  File explorer', ':Neotree toggle<CR>'),
        dashboard.button('c', '  Config',        ':edit ~/.config/nvim/init.lua<CR>'),
        dashboard.button('q', '  Quit',          ':qa<CR>'),
      }

      dashboard.section.footer.val = 'Happy coding!'

      alpha.setup(dashboard.config)
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
        { '<leader>h', group = 'hunk' },
        { '<leader>r', group = 'rename' },
        { '<leader>c', group = 'code' },
        { '<leader>e', desc = 'explorer' },
        { '<leader>g', group = 'git' },
        { '<leader>x', group = 'trouble' },
      })
    end,
  },

})


