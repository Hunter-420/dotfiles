
return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" }
    },
    config = function()
        local builtin = require('telescope.builtin')
        
        -- Fix crash by disabling treesitter in previewer if needed, 
        -- or just relying on standard setup which usually works on 0.1.x.
        -- The crash "attempt to call field 'ft_to_lang' (a nil value)" suggests bad interaction 
        -- between treesitter and telescope previewers. 
        -- WORKAROUND: Disable treesitter highlighting in previewers.
        
        vim.api.nvim_create_autocmd("User", {
            pattern = "TelescopePreviewerLoaded",
            callback = function(args)
                -- Safe guard against nil data
                if args.data and args.data.bufname then
                    if args.data.bufname:match("%.min%.") then
                        vim.opt_local.wrap = true 
                    end
                end
                -- Force disable treesitter/syntax in preview buffer to prevent crash
                vim.cmd "setlocal syntax=off" 
            end,
        })

        -- Robust Keymaps
        vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Find Project Files' })
        vim.keymap.set('n', '<leader>pa', function() 
            builtin.find_files({ no_ignore = true, hidden = true }) 
        end, { desc = 'Find All Files (Hidden/Ignored)' })
        
        vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'Git Files' })
        
        -- Live Grep (Search by content)
        vim.keymap.set('n', '<leader>ps', function()
             builtin.live_grep()
        end, { desc = 'Search by Content (Live Grep)' })

        -- Grep String under cursor
        vim.keymap.set('n', '<leader>pw', function()
             builtin.grep_string()
        end, { desc = 'Search Word under cursor' })

        vim.keymap.set('n', '<leader>vcs', function()
            builtin.lsp_document_symbols()
        end, { desc = 'View Code Symbols (Classes/Functions)' })

        -- List all Diagnostics (Errors/Warnings) in current file
        vim.keymap.set('n', '<leader>ve', function()
            builtin.diagnostics({ bufnr = 0 })
        end, { desc = 'View Errors/Diagnostics in file' })

        require("telescope").setup({
            defaults = {
                file_ignore_patterns = { "node_modules", ".git" },
                preview = {
                    treesitter = false -- DISABLES treesitter in preview to Fix Crash
                }
            }
        })
    end
}
