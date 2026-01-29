
return {
    {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            require('rose-pine').setup({
                disable_background = true
            })
            -- vim.cmd('colorscheme rose-pine')
        end
    },
    {
        "sainnhe/gruvbox-material",
        config = function()
            vim.cmd.colorscheme('gruvbox-material')
            -- Fix transparency for gruvbox if needed
            vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
            vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        end
    }
}
