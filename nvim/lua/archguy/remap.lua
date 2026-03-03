vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open netrw file explorer" })

-- Move selected lines up/down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected line down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected line up" })

-- Cursor stays in place when joining lines
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join line below to current line, cursor stays in place. E.g: turns 2 lines into 1" })

-- Keep cursor in middle when scrolling half pages
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down half page and center screen on cursor" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up half page and center screen on cursor" })

-- Keep cursor centered during search navigation
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result, center cursor and open folds" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result, center cursor and open folds" })

vim.keymap.set("n", "<leader>vwm", function()
    require("vim-with-me").StartVimWithMe()
end, { desc = "Start Vim With Me" })
vim.keymap.set("n", "<leader>svwm", function()
    require("vim-with-me").StopVimWithMe()
end, { desc = "Stop Vim With Me" })

-- Paste over selection without replacing the paste buffer (greatest remap ever)
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste over visual selection without losing original yanked text. E.g: Select 'bad', hit <leader>p to replace it with yanked 'good'" })

-- Yank into system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], { desc = "Yank to system clipboard so you can paste outside Neovim" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank rest of line to system clipboard" })

-- Delete without yanking
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]], { desc = "Delete text into void register (discard it) instead of overriding yank history" })

-- This is going to get me cancelled (Ctrl-C acts like Escape)
vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Make Ctrl+C act like Escape" })

vim.keymap.set("n", "Q", "<nop>", { desc = "Disable Ex Mode 'Q' mapping" })

-- Tmux sessionizer
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Open tmux-sessionizer" })

-- Format current buffer
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format current buffer (LSP)" })

-- Quickfix list navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Next item in quickfix list" }) 
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Prev item in quickfix list" })

-- Location list navigation
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Next item in location list" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Prev item in location list" })

-- Search and replace word under cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Search and replace exact word under cursor across all lines. E.g: Replaces all standalone 'foo' with whatever you type" })

-- Make current file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make current file executable" })

vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>", { desc = "CellularAutomaton: Make it rain" });

-- Source current file
vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("source %")
end, { desc = "Source current file" })
