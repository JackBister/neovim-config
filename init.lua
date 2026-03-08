vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.splitbelow = true
vim.opt.splitright = true

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

		lsp_zero.on_attach(function(client, bufnr)
		    lsp_zero.default_keymaps({buffer = bufnr})
		end)

		require("mason").setup()
		require("mason-lspconfig").setup({
		    ensure_installed = {
			-- See https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
			"gopls", -- Go
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
	}
})

