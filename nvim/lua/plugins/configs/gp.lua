require("gp").setup({
  providers = {
		openai = {
      disable = true,
			endpoint = "https://api.openai.com/v1/chat/completions",
      secret = { "op", "read", "op://Private/6uzg7fnpd6zhrounkm7nfmsfri/token", "--no-newline" },
		},

		ollama = {
      disable = true,
			endpoint = "http://localhost:11434/v1/chat/completions",
		},

		anthropic = {
      disable = true,
			endpoint = "https://api.anthropic.com/v1/messages",
      secret = { "op", "read", "op://Private/qlncjzrznexfno6uuwyj7j2yme/api_token", "--no-newline" },
		},

    copilot = {
			endpoint = "https://api.githubcopilot.com/chat/completions",
			secret = {
				"bash",
				"-c",
				"cat ~/.config/github-copilot/hosts.json | sed -e 's/.*oauth_token...//;s/\".*//'",
			},
		},
	},
})

vim.keymap.set('n', '<leader>go', ':GpChatToggle<CR>', { silent = true })
vim.keymap.set('n', '<leader>gn', ':GpChatNew<CR>', { silent = true })
