local module = {}

local function upload_file(filepath, ftp_config)
	local script_path = os.tmpname() .. ".ftp"
	local script = string.format(
		[[
			open %s
			user %s %s
			binary
			put "%s" "%s"
			bye
			]],
		ftp_config.host,
		ftp_config.user,
		ftp_config.password,
		filepath,
		ftp_config.remote_path
	)

	-- Write the script to a temp file
	local f = io.open(script_path, "w")
	f:write(script)
	f:close()

	-- Run the FTP command
	local cmd = string.format('ftp -s:"%s"', script_path)
	os.execute(cmd)

	-- Clean up
	os.remove(script_path)
end

function module.setup(opts)
	local ftp_config = opts or {}
	vim.keymap.set("n", "<Leader>su", function()
		local filepath = vim.api.nvim_buf_get_name(0)
		upload_file(filepath, ftp_config)
	end, { desc = "Upload current file" })
end

return module
