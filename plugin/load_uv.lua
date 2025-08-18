vim.api.nvim_create_user_command("UVRun", function()
	-- package.loaded["uv"] = nil

	require("uv").run()
end, {})
