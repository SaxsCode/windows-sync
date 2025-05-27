local module = {}

function module.setup(opts)
	opts = opts or {}

	vim.keymap.set("n", "<Leader>su", function()
		print("upload")
	end)
end

return module
