vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.splitbelow = true
vim.opt.splitright = true

local opam_share = vim.fn.trim(vim.fn.system({ "opam", "var", "share" }))
local ocp_indent_vim = opam_share .. "/ocp-indent/vim"
if vim.v.shell_error == 0 and vim.loop.fs_stat(ocp_indent_vim) then
	vim.opt.rtp:prepend(ocp_indent_vim)
end

-- Visit the project page for the latest installation instructions
-- https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"https://github.com/junegunn/fzf.vim",
		dependencies = {
			"https://github.com/junegunn/fzf",
		},
		keys = {
		    { "<Leader><Leader>", "<Cmd>Files<CR>", desc = "Find files" },
		    { "<Leader>,", "<Cmd>Buffers<CR>", desc = "Find buffers" },
		    { "<Leader>/", "<Cmd>Rg<CR>", desc = "Search project" },
		},
	},
	{
		"https://github.com/stevearc/oil.nvim",
		config = function()
		    require("oil").setup()
		end,
		keys = {
		    { "-", "<Cmd>Oil<CR>", desc = "Browse files from here" },
		},
	},
	{
	    "nvim-neo-tree/neo-tree.nvim",
	    branch = "v3.x",
	    cmd = "Neotree",
	    dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	    },
	    keys = {
		{ "<C-b>", "<Cmd>Neotree toggle filesystem reveal left<CR>", desc = "Toggle file explorer" },
		{ "<leader>e", "<Cmd>Neotree toggle filesystem reveal left<CR>", desc = "Toggle file explorer" },
		{ "<leader>o", "<Cmd>Neotree focus filesystem left<CR>", desc = "Focus file explorer" },
	    },
	    config = function()
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		require("neo-tree").setup({
		    close_if_last_window = true,
		    filesystem = {
			follow_current_file = { enabled = true },
			hijack_netrw_behavior = "open_default",
		    },
		    window = {
			position = "left",
			width = 32,
		    },
		})
	    end,
	},
	{
	    "akinsho/toggleterm.nvim",
	    version = "*",
	    keys = {
		{ "<leader>t", "<Cmd>ToggleTerm direction=horizontal<CR>", desc = "Toggle terminal" },
	    },
	    config = function()
		require("toggleterm").setup({
		    direction = "horizontal",
		    persist_size = true,
		    size = 8,
		    start_in_insert = true,
		})

		vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
	    end,
	},
	{
		"https://github.com/windwp/nvim-autopairs",
		event = "InsertEnter", -- Only load when you enter Insert mode
		config = function()
		    require("nvim-autopairs").setup()
		end,
	},
	{
		"https://github.com/numToStr/Comment.nvim",
		event = "VeryLazy", -- Special lazy.nvim event for things that can load later and are not important for the initial UI
		config = function()
		    require("Comment").setup()
		end,
	},
	{
		"https://github.com/tpope/vim-sleuth",
		event = { "BufReadPost", "BufNewFile" }, -- Load after your file content
	},
	{
	    "https://github.com/VonHeikemen/lsp-zero.nvim",
	    dependencies = {
		"https://github.com/williamboman/mason.nvim",
		"https://github.com/williamboman/mason-lspconfig.nvim",
		"https://github.com/neovim/nvim-lspconfig",
		"https://github.com/hrsh7th/cmp-nvim-lsp",
		"https://github.com/hrsh7th/nvim-cmp",
		"https://github.com/L3MON4D3/LuaSnip",
	    },
	    config = function()
		local lsp_zero = require('lsp-zero')
		local cmp = require("cmp")

		cmp.setup({
		    sources = {
			{ name = "nvim_lsp" },
		    },
		    mapping = cmp.mapping.preset.insert({
			["<C-Space>"] = cmp.mapping.complete(),
			["<CR>"] = cmp.mapping.confirm({ select = true }),
			["<Tab>"] = cmp.mapping.select_next_item(),
			["<S-Tab>"] = cmp.mapping.select_prev_item(),
		    }),
		})

		vim.diagnostic.config({
		    virtual_text = true,
		    signs = true,
		    underline = true,
		    severity_sort = true,
		    float = {
			source = "if_many",
			border = "rounded",
		    },
		})

		vim.api.nvim_create_autocmd("CursorHold", {
		    callback = function()
			vim.diagnostic.open_float(nil, {
			    focusable = false,
			    scope = "cursor",
			    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
			})
		    end,
		})

		vim.keymap.set("n", "<leader>dn", function()
		    vim.diagnostic.jump({ count = 1, float = true })
		end, { desc = "Next diagnostic" })
		vim.keymap.set("n", "<leader>dp", function()
		    vim.diagnostic.jump({ count = -1, float = true })
		end, { desc = "Previous diagnostic" })
		vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Show diagnostic" })

		lsp_zero.on_attach(function(client, bufnr)
		    lsp_zero.default_keymaps({buffer = bufnr})
		end)

		require("mason").setup()
		require("mason-lspconfig").setup({
		    ensure_installed = {
			-- See https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
			"gopls", -- Go
			"ocamllsp", -- OCaml
			"pyright", -- Python
			"roslyn_ls",
			"rust_analyzer", -- Rust
			"ts_ls"
		    },
		    handlers = {
			lsp_zero.default_setup,
		    },
		})
	    end,
	},
	{
	    "https://github.com/farmergreg/vim-lastplace",
	    event = "BufReadPost",
	},
	{
	    "https://github.com/lukas-reineke/indent-blankline.nvim",
	    event = { "VeryLazy" },
	    config = function()
		require("ibl").setup()
	    end,
	},
	{
	    "NeogitOrg/neogit",
	    lazy = true,
	    dependencies = {
		"nvim-lua/plenary.nvim",         -- required

		-- Only one of these is needed.
		"sindrets/diffview.nvim",        -- optional
		"esmuellert/codediff.nvim",      -- optional

		-- Only one of these is needed.
		"nvim-telescope/telescope.nvim", -- optional
		"ibhagwan/fzf-lua",              -- optional
		"nvim-mini/mini.pick",           -- optional
		"folke/snacks.nvim",             -- optional
	  },
	  cmd = "Neogit",
	  keys = {
	    { "<leader>gg", "<cmd>Neogit<cr>", desc = "Show Neogit UI" }
	  }
	},
	{
	  "stevearc/conform.nvim",
	  event = { "BufWritePre" },
	  cmd = { "ConformInfo" },
	  keys = {
	    {
	      -- Customize or remove this keymap to your liking
	      "<leader>f",
	      function()
		require("conform").format({ async = true })
	      end,
	      mode = "",
	      desc = "Format buffer",
	    },
	  },
	  opts = {
	    -- Define your formatters
	    formatters_by_ft = {
	      cs = { "csharpier" },
	      go = { "goimports", "gofmt" },
	      lua = { "stylua" },
	      ocaml = { "ocamlformat" },
	      ocamlinterface = { "ocamlformat" },
	      javascript = { "prettierd", "prettier", stop_after_first = true },
	      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
	      typescript = { "prettierd", "prettier", stop_after_first = true },
	      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
	    },
	    -- Set default options
	    default_format_opts = {
	      lsp_format = "fallback",
	    },
	    -- Set up format-on-save
	    format_on_save = { timeout_ms = 500 },
	    -- Customize formatters
	    formatters = {
	      shfmt = {
		append_args = { "-i", "2" },
	      },
	    },
	  },
	  init = function()
	    -- If you want the formatexpr, here is the place to set it
	    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	  end,
	},
	{
	    'nvim-treesitter/nvim-treesitter',
	    lazy = false,
	    build = ':TSUpdate',
	    opts = {
		-- LazyVim config for treesitter
		indent = { enable = true }, ---@type lazyvim.TSFeat
		highlight = { enable = true }, ---@type lazyvim.TSFeat
		folds = { enable = true }, ---@type lazyvim.TSFeat
		ensure_installed = {
		  "bash",
		  "c",
		  "c_sharp",
		  "diff",
		  "go",
		  "html",
		  "javascript",
		  "jsdoc",
		  "json",
		  "markdown",
		  "markdown_inline",
		  "ocaml",
		  "printf",
		  "regex",
		  "tsx",
		  "typescript",
		  "yaml",
	        },
	    },
	},
	{
	    "tarides/ocaml.nvim",
	    config = function()
		require("ocaml").setup({
		    keymaps = {
			jump_next_hole = "<leader>n",
			jump_prev_hole = "<leader>p",
			construct = "<leader>c",
			jump = "<leader>j",
			phrase_prev = "<leader>pp",
			phrase_next = "<leader>pn",
			infer = "<leader>i",
			switch_ml_mli = "<leader>s",
			type_enclosing = "<leader>ot",
			type_enclosing_grow = "<Up>",
			type_enclosing_shrink = "<Down>",
			type_enclosing_increase = "<Right>",
			type_enclosing_decrease = "<Left>",
		    },
		})
	    end
	}
})
