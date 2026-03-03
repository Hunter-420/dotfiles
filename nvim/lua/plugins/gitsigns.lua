
return {
    "lewis6991/gitsigns.nvim",
    config = function()
        require('gitsigns').setup({
            signs = {
                add          = { text = '│' },
                change       = { text = '│' },
                delete       = { text = '_' },
                topdelete    = { text = '‾' },
                changedelete = { text = '~' },
                untracked    = { text = '┆' },
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map('n', ']c', function()
                    if vim.wo.diff then return ']c' end
                    vim.schedule(function() gs.next_hunk() end)
                    return '<Ignore>'
                end, { expr = true, desc = "Next Git Hunk" })

                map('n', '[c', function()
                    if vim.wo.diff then return '[c' end
                    vim.schedule(function() gs.prev_hunk() end)
                    return '<Ignore>'
                end, { expr = true, desc = "Previous Git Hunk" })

                -- Actions
                map('n', '<leader>hs', gs.stage_hunk, { desc = "Stage Git Hunk" })
                map('n', '<leader>hr', gs.reset_hunk, { desc = "Reset Git Hunk" })
                map('n', '<leader>hS', gs.stage_buffer, { desc = "Stage Git Buffer" })
                map('n', '<leader>hu', gs.undo_stage_hunk, { desc = "Undo Stage Git Hunk" })
                map('n', '<leader>hR', gs.reset_buffer, { desc = "Reset Git Buffer" })
                map('n', '<leader>hp', gs.preview_hunk, { desc = "Preview Git Hunk" })
                map('n', '<leader>hb', function() gs.blame_line { full = true } end, { desc = "Git Blame Line" })
                map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = "Toggle Git Blame" })
                map('n', '<leader>hd', gs.diffthis, { desc = "Git Diff This" })
                map('n', '<leader>hD', function() gs.diffthis('~') end, { desc = "Git Diff This (~)" })
                map('n', '<leader>td', gs.toggle_deleted, { desc = "Toggle Git Deleted" })

                -- Text object
                map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = "Select Git Hunk" })
            end
        })
    end
}
