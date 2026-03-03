return {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("nvim-tree").setup({
            view = {
                -- Right side placement as requested
                side = "right",
            },
        })

        -- Toggle the file explorer
        vim.keymap.set("n", "<leader>e", vim.cmd.NvimTreeToggle, { desc = "Toggle NvimTree Explorer (Right side)" })
    end,
}
