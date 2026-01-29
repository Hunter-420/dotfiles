
return {
    {
        "mbbill/undotree",
        config = function()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
        end
    },
    {
        "tpope/vim-fugitive",
        config = function()
            vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
        end
    },
    {
        "vimwiki/vimwiki"
    },
    {
        "m4xshen/hardtime.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
        opts = {}
    },
    {
        "tris203/precognition.nvim",
        -- event = "VeryLazy",
        -- opts = {
        --    startVisible = true,
        --    showBlankVirtLine = true,
        --    highlightColor = { link = "Comment" },
        --    hints = {
        --       Caret = { text = "^", prio = 1 },
        --       Dollar = { text = "$", prio = 1 },
        --       MatchingPair = { text = "%", prio = 5 },
        --       Zero = { text = "0", prio = 1 },
        --       w = { text = "w", prio = 10 },
        --       b = { text = "b", prio = 10 },
        --       e = { text = "e", prio = 10 },
        --       W = { text = "W", prio = 10 },
        --       B = { text = "B", prio = 10 },
        --       E = { text = "E", prio = 10 },
        --    },
        --    gutterHints = {
        --       G = { text = "G", prio = 10 },
        --       gg = { text = "gg", prio = 10 },
        --       PrevParagraph = { text = "{", prio = 10 },
        --       NextParagraph = { text = "}", prio = 10 },
        --    },
        -- },
    }
}
