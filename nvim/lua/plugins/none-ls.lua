
return {
    "nvimtools/none-ls.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "jay-babu/mason-null-ls.nvim",
    },
    config = function()
        require("mason-null-ls").setup({
            ensure_installed = nil,
            automatic_installation = true, -- This auto-installs linters/formatters for opened files!
        })

        local null_ls = require("null-ls")
        null_ls.setup({
            sources = {
                -- Anything not supported by mason-null-ls or manual additions
            }
        })
    end
}
