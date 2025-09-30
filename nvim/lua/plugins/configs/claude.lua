return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = true,
  keys = {
    { "<C-a>", "<cmd>ClaudeCode<cr>", mode = { "t" }, desc = "Toggle Claude" },
    { "<C-a>", "<cmd>ClaudeCodeFocus<cr>", mode = { "n" }, desc = "Focus Claude" },
    { "<C-h>", "<C-\\><C-n><C-w>h", mode = { "t" }, desc = "Focus to editor mode from terminal" },
    { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>cm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    -- Diff management
    { "<localleader>a", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<localleader>d", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
