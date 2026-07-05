-- ==========================================================================
-- Neovim config — lazy.nvim
-- ==========================================================================

-- ---------------------------------------------------------------------------
-- Leader (must be set before lazy.nvim)
-- ---------------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ---------------------------------------------------------------------------
-- Clipboard — OSC 52 (works over SSH through tmux to iTerm2)
-- ---------------------------------------------------------------------------
local osc52 = require("vim.ui.clipboard.osc52")
vim.g.clipboard = {
    name = "OSC 52",
    copy = {
        ["+"] = osc52.copy("+"),
        ["*"] = osc52.copy("*"),
    },
    paste = {
        ["+"] = osc52.paste("+"),
        ["*"] = osc52.paste("*"),
    },
}

-- ---------------------------------------------------------------------------
-- Options
-- ---------------------------------------------------------------------------
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.clipboard = "unnamedplus"
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.wrap = true
vim.o.termguicolors = true
vim.o.hidden = true
vim.o.signcolumn = "yes"
vim.o.autoread = true
vim.o.updatetime = 250
vim.o.undofile = true
vim.o.scrolloff = 8

-- ---------------------------------------------------------------------------
-- Auto-reload files changed externally (e.g. by Claude Code)
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
    command = "if mode() != 'c' | checktime | endif",
})

-- ---------------------------------------------------------------------------
-- Basic keymaps
-- ---------------------------------------------------------------------------
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

-- ---------------------------------------------------------------------------
-- Bootstrap lazy.nvim
-- ---------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- ---------------------------------------------------------------------------
-- Plugins
-- ---------------------------------------------------------------------------
require("lazy").setup({

    -- ── Theme ──────────────────────────────────────────────────────────
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = function()
            vim.o.background = "dark"
            vim.cmd.colorscheme("gruvbox")
            -- Suppress red highlighting of bare underscores in markdown
            vim.api.nvim_set_hl(0, "markdownError", {})
        end,
    },

    -- ── Fuzzy finder ───────────────────────────────────────────────────
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope live_grep<CR>",  desc = "Live grep" },
            { "<leader>fb", "<cmd>Telescope buffers<CR>",    desc = "Buffers" },
        },
        opts = {
            defaults = {
                find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
            },
        },
    },

    -- ── Treesitter ─────────────────────────────────────────────────────
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            -- Parsers are installed via :TSInstall; highlight/indent are built-in in nvim 0.11
            require("nvim-treesitter").setup()
            -- Install desired parsers if missing
            local wanted = { "python", "lua", "bash", "json", "yaml", "markdown", "markdown_inline" }
            local installed = require("nvim-treesitter").get_installed()
            local installed_set = {}
            for _, p in ipairs(installed) do installed_set[p] = true end
            local missing = {}
            for _, p in ipairs(wanted) do
                if not installed_set[p] then table.insert(missing, p) end
            end
            if #missing > 0 then
                vim.cmd("TSInstall " .. table.concat(missing, " "))
            end
        end,
    },

    -- ── LSP ────────────────────────────────────────────────────────────
    {
        "neovim/nvim-lspconfig",
        dependencies = { "hrsh7th/cmp-nvim-lsp" },
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- nvim 0.11+ API
            vim.lsp.config("pyright", {
                capabilities = capabilities,
            })
            vim.lsp.enable("pyright")

            -- LSP keymaps (set on attach)
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
                    vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Go to references" }))
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover" }))
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
                end,
            })
        end,
    },

    -- ── Completion ─────────────────────────────────────────────────────
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            { "L3MON4D3/LuaSnip", build = "make install_jsregexp" },
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            cmp.setup({
                snippet = {
                    expand = function(args) luasnip.lsp_expand(args.body) end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
                        else fallback() end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then luasnip.jump(-1)
                        else fallback() end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                }),
            })
        end,
    },

    -- ── Git signs ──────────────────────────────────────────────────────
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                current_line_blame = false,
            })
        end,
    },

    -- ── Status line ────────────────────────────────────────────────────
    {
        "nvim-lualine/lualine.nvim",
        config = function()
            require("lualine").setup({
                options = { theme = "gruvbox" },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { "filename" },
                    lualine_x = { "encoding", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            })
        end,
    },

    -- ── File explorer (buffer-style) ───────────────────────────────────
    {
        "stevearc/oil.nvim",
        keys = {
            { "<leader>e", "<cmd>Oil<CR>", desc = "File explorer (oil)" },
        },
        config = function()
            require("oil").setup()
        end,
    },

    -- ── File tree (sidebar) ────────────────────────────────────────────
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
        },
        keys = {
            { "<leader>t", "<cmd>Neotree toggle<CR>", desc = "File tree" },
            { "<leader>T", "<cmd>Neotree reveal<CR>", desc = "File tree (reveal current)" },
        },
        config = function()
            require("neo-tree").setup({
                filesystem = {
                    follow_current_file = { enabled = true },
                    filtered_items = {
                        hide_dotfiles = false,
                        hide_gitignored = false,
                    },
                },
                window = {
                    width = 35,
                },
            })
        end,
    },

    -- ── Which-key ──────────────────────────────────────────────────────
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("which-key").setup()
        end,
    },

    -- ── Comments ───────────────────────────────────────────────────────
    {
        "numToStr/Comment.nvim",
        keys = {
            { "gcc", mode = "n", desc = "Toggle comment" },
            { "gc", mode = "v", desc = "Toggle comment" },
            { "<leader>/", function() require("Comment.api").toggle.linewise.current() end, mode = "n", desc = "Toggle comment" },
        },
        config = function()
            require("Comment").setup()
        end,
    },

    -- ── Autopairs ──────────────────────────────────────────────────────
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup()
        end,
    },

    -- ── Markdown rendering ─────────────────────────────────────────────
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        ft = { "markdown" },
        config = function()
            require("render-markdown").setup()
        end,
    },
})

-- ---------------------------------------------------------------------------
-- Markdown concealment (hide link URLs unless cursor is on that line)
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.treesitter.start()
        vim.wo.conceallevel = 2
        vim.wo.concealcursor = ""  -- reveal concealed text on cursor line
    end,
})

-- ---------------------------------------------------------------------------
-- Diagnostics navigation
-- ---------------------------------------------------------------------------
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
