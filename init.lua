-- ============
-- Core configs
-- ============
vim.g.mapleader = ","

-- Desabilitar netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1


vim.o.clipboard = "unnamedplus"
vim.o.mouse = "a"
vim.o.number = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.termguicolors = true
vim.o.relativenumber = true

vim.cmd[[colorscheme minimalist]]

-- ============
-- Key Bindings
-- ============
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('n', 'q', ':q<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>a', { noremap = true, silent = true })

-- ================
-- Packer VIM setup
-- ================

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data").."/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require("packer").startup(function(use)
  use "wbthomason/packer.nvim"

  -- LSP
  use "neovim/nvim-lspconfig"
  use "williamboman/mason.nvim"
  use "williamboman/mason-lspconfig.nvim"

  -- Autocomplete
  use "hrsh7th/nvim-cmp"
  use "hrsh7th/cmp-nvim-lsp"
  use "jiangmiao/auto-pairs"

  -- UI / Quality of life
  use "nvim-tree/nvim-tree.lua"
  use { "nvim-telescope/telescope.nvim", requires = { "nvim-lua/plenary.nvim" } }
  use "lewis6991/gitsigns.nvim"
  use "itchyny/lightline.vim"
  use "dikiaap/minimalist"



  if packer_bootstrap then
    require("packer").sync()
  end
end)


-- ===================
-- Extra Setup Plugins
-- ===================

-- Mason + LSP
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "eslint", "html", "cssls", "jsonls", "lua_ls", "ts_ls" }
})

-- LSP
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local servers = { "ts_ls", "eslint", "html", "cssls", "jsonls", "lua_ls" }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup({
    capabilities = capabilities,
  })
end

-- Função auxiliar
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Modo normal, keymaps LSP
local on_attach = function(client, bufnr)
  local bufopts = { noremap=true, silent=true, buffer=bufnr }

  -- Go to definition
  keymap("n", "gd", vim.lsp.buf.definition, bufopts)

  -- Go to declaration
  keymap("n", "gD", vim.lsp.buf.declaration, bufopts)

  -- Show hover documentation
  keymap("n", "K", vim.lsp.buf.hover, bufopts)

  -- Go to implementation
  keymap("n", "gi", vim.lsp.buf.implementation, bufopts)

  -- List references
  keymap("n", "gr", vim.lsp.buf.references, bufopts)

  -- Signature help
  keymap("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)

  -- Rename symbol
  keymap("n", "<leader>rn", vim.lsp.buf.rename, bufopts)

  -- Code actions
  keymap("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)

  -- Format
  keymap("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, bufopts)
end

-- Adicionar on_attach ao setup do LSP
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup({
    capabilities = capabilities,
    on_attach = on_attach, -- <<< aqui
  })
end


-- Autocomplete
local cmp = require("cmp")

-- cmp.setup({
--   snippet = {
--     expand = function(args) require("luasnip").lsp_expand(args.body) end,
--   },
--   mapping = cmp.mapping.preset.insert({
--     ["<C-Space>"] = cmp.mapping.complete(),
--     ["<CR>"] = cmp.mapping.confirm({ select = true }),
--   }),
--   sources = cmp.config.sources({
--     { name = "nvim_lsp" },
--     { name = "luasnip" },
--   }),
-- })
cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),           -- abrir manualmente
    ["<CR>"] = cmp.mapping.confirm({ select = true }),-- confirmar sugestão

    -- Tab para navegar pelas opções do autocomplete
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }),
})

-- UI
require("gitsigns").setup()


require("nvim-tree").setup({
  hijack_netrw = true,    -- Hijack netrw window
  update_cwd = true,      -- Update current working directory
  view = {
    width = 30,           -- Tree width
    side = "left",        -- Side of the window
  },
  renderer = {
    icons = {
      show = {
        file = false,    -- Disable file icons
        folder = false,  -- Disable folder icons
        folder_arrow = true, -- Disable folder arrows
        git = false,     -- Disable git icons
      },
    },
  },
  git = {
    enable = false,       -- Disable git integration icons
  },
})



local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
