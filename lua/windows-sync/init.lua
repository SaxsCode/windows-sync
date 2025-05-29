local module = {}

local function get_ftp_config()
	local config_path = vim.fn.getcwd() .. "/ftp_config.lua"
	local ok, config = pcall(dofile, config_path)
	if ok then
		return config
	else
		print("Error: No project FTP config found or error in config file.")
		return nil
	end
end

local function upload_file_with_winscp(filepath, ftp_config)
	-- Compute remote path as before
	local config_directory = vim.fn.fnamemodify(vim.fn.getcwd(), ":p")
	local project_root = ftp_config.project_root or config_directory
	if project_root:sub(1, 1) ~= "/" and project_root:sub(2, 2) ~= ":" then
		project_root = vim.fn.fnamemodify(config_directory .. "/" .. project_root, ":p")
	else
		project_root = vim.fn.fnamemodify(project_root, ":p")
	end
	local relative_path = vim.fn.fnamemodify(filepath, ":p")
	relative_path = relative_path:gsub(project_root, "")
	relative_path = relative_path:gsub("\\", "/")

	local remote_base = ftp_config.remote_path
	if remote_base:sub(-1) ~= "/" then
		remote_base = remote_base .. "/"
	end
	local remote_path = remote_base .. relative_path

	local escaped_filepath = filepath:gsub("\\", "/")

	-- WinSCP command (create directory and upload file)
	local remote_dir = remote_path:match("(.*/)") or remote_base
	local cmd = string.format(
		'winscp.com /command "open ftp://%s:%s@%s/" "mkdir %s" "put "%s" "%s"" "exit"',
		ftp_config.user,
		ftp_config.password,
		ftp_config.host,
		remote_dir,
		escaped_filepath,
		remote_path
	)

	-- Execute the command
	local result = os.execute(cmd)
	if result == 0 then
		print("Success: Uploaded " .. filepath .. " to " .. remote_path)
	else
		print("Error: Upload failed.")
	end
end

function module.setup(opts)
	local key = opts.keymap or "<Leader>fu"
	vim.keymap.set("n", key, function()
		local ftp_config = get_ftp_config()
		if not ftp_config then
			print("Error: No valid FTP config for this project.")
			return
		end
		local filepath = vim.api.nvim_buf_get_name(0)
		upload_file_with_winscp(filepath, ftp_config)
	end, { desc = "Upload current file" })
end

return module
