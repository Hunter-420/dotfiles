
return {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v4.x",
    dependencies = {
        -- LSP Support
        { "neovim/nvim-lspconfig" },
        { "williamboman/mason.nvim" },
        { "williamboman/mason-lspconfig.nvim" },
        { "whoissethdaniel/mason-tool-installer.nvim" },

        -- Autocompletion
        { "hrsh7th/nvim-cmp" },
        { "hrsh7th/cmp-buffer" },
        { "hrsh7th/cmp-path" },
        { "saadparwaiz1/cmp_luasnip" },
        { "hrsh7th/cmp-nvim-lsp" },
        { "hrsh7th/cmp-nvim-lua" },

        -- Snippets
        { "L3MON4D3/LuaSnip" },
        { "rafamadriz/friendly-snippets" },
    },
    config = function()
        local lsp_zero = require("lsp-zero")

        local lsp_attach = function(client, bufnr)
            local opts = { buffer = bufnr }

            vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
            vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
            vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
            vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
            vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
            vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
            vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
            vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
            vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
            vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
            
            vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
            vim.keymap.set("n", "<leader>vp", function() vim.diagnostic.open_float() end, opts) -- Requested: View Popup
            vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
            vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
            vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
            vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
            vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)

            -- FIX: Robust Diagnostic Toggle
            vim.keymap.set("n", "<leader>vt", function()
                local config = vim.diagnostic.config()
                -- If virtual_text is currently a table or true, disabling it means setting it to false
                -- If it's false, we enable it (true or table)
                local current_vt = config.virtual_text
                local is_enabled = false
                
                if type(current_vt) == "table" then
                   is_enabled = true -- It's enabled with options
                elseif current_vt == true then
                   is_enabled = true
                end

                if is_enabled then
                    vim.diagnostic.config({ virtual_text = false })
                    print("Diagnostics: Inline OFF")
                else
                    vim.diagnostic.config({ virtual_text = { source = "always" } })
                    print("Diagnostics: Inline ON")
                end
            end, { buffer = bufnr, desc = "Toggle inline diagnostics" })
        end

        lsp_zero.extend_lspconfig({
            sign_text = true,
            lsp_attach = lsp_attach,
            capabilities = require('cmp_nvim_lsp').default_capabilities(),
        })

        require("mason").setup({})
        require("mason-tool-installer").setup({
            ensure_installed = {
                "prettier", "stylua", "eslint_d", "isort", "black"
            },
        })

        require("mason-lspconfig").setup({
            ensure_installed = {
                'rust_analyzer', 'clangd', 'html', 'jdtls', 'pylsp',
                'css_variables', 'eslint', 'lua_ls', 'ts_ls', -- ADDED ts_ls for JS/TS support!
            },
            handlers = {
                function(server_name)
                    require('lspconfig')[server_name].setup({})
                end,
                lua_ls = function()
                    local lua_opts = lsp_zero.nvim_lua_ls()
                    require('lspconfig').lua_ls.setup(lua_opts)
                end,
            }
        })

        local cmp = require('cmp')
        local cmp_select = { behavior = cmp.SelectBehavior.Select }
        
        cmp.setup({
            sources = {
                { name = 'path' },
                { name = 'nvim_lsp' },
                { name = 'nvim_lua' },
                { name = 'luasnip', keyword_length = 2 },
                { name = 'buffer', keyword_length = 3 }, -- Added buffer source
            },
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                ['<C-Space>'] = cmp.mapping.complete(),
            }),
            formatting = {
                fields = {'menu', 'abbr', 'kind'},
                format = function(entry, item)
                    local menu_icon = {
                        nvim_lsp = 'λ',
                        luasnip = '⋗',
                        buffer = 'Ω',
                        path = '🖫',
                        nvim_lua = 'Π',
                    }
                    item.menu = menu_icon[entry.source.name]
                    return item
                end,
            },
        })

        -- Initial Diagnostic Config: Hidden by default (E only)
        vim.diagnostic.config({
            virtual_text = false, 
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = "E",
                    [vim.diagnostic.severity.WARN] = "W",
                    [vim.diagnostic.severity.HINT] = "H",
                    [vim.diagnostic.severity.INFO] = "I",
                },
            },
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
