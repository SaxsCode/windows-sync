local module = {}

local function get_ftp_config()
	local config_path = vim.fn.getcwd() .. "/ftp_config.lua"
	local ok, config = pcall(dofile, config_path)
	if ok then
		return config
	else
		print("No project FTP config found or error in config file.")
		return nil
	end
end

local function upload_file(filepath, ftp_config)
	if vim.loop.os_uname().sysname ~= "Windows_NT" then
		print("windows-ftp does not work on " .. vim.loop.os_uname().sysname)
		return
	end

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
	print("File uploaded to remote server: " .. ftp_config.host .. ftp_config.remote_path .. )

	-- Clean up
	os.remove(script_path)
end

function module.setup(opts)
	local key = opts.keymap or "<Leader>fu"
	vim.keymap.set("n", key, function()
		local ftp_config = get_ftp_config()
		if not ftp_config then
			print("No valid FTP config for this project.")
			return
		end
		local filepath = vim.api.nvim_buf_get_name(0)
		upload_file(filepath, ftp_config)
	end, { desc = "Upload current file" })
end

return module
