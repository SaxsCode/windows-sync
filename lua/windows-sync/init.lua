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

local function upload_file_with_curl(filepath, ftp_config)
	-- Construct FTP URL with credentials
	local ftp_url =
		string.format("ftp://%s:%s@%s%s", ftp_config.user, ftp_config.password, ftp_config.host, ftp_config.remote_path)

	-- Escape backslashes in Windows path for curl
	local escaped_filepath = filepath:gsub("\\", "/")

	-- Build curl command
	local cmd = string.format('curl -T "%s" "%s"', escaped_filepath, ftp_url)

	-- Execute the command
	local result = os.execute(cmd)
	if result == 0 then
		print("[ftp-upload] Success: Uploaded " .. filepath .. " to " .. ftp_url)
	else
		print("[ftp-upload] Error: Upload failed.")
	end
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
		upload_file_with_curl(filepath, ftp_config)
	end, { desc = "Upload current file" })
end

return module
