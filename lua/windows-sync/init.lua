local module = {}

local function get_ftp_config()
	local config_path = vim.fn.getcwd() .. "/ftp_config.lua"
	local ok, config = pcall(dofile, config_path)
	return ok and config or nil
end

local function url_encode(str)
	if str then
		str = str:gsub("\n", "\r\n")
		str = str:gsub("([^%w _%%%-%.~])", function(c)
			return string.format("%%%02X", string.byte(c))
		end)
		str = str:gsub(" ", "+")
	end
	return str
end

local function upload_file_with_winscp(filepath, ftp_config)
	-- Path of project root
	local project_root = ftp_config.project_root or vim.fn.getcwd()
	project_root = vim.fn.fnamemodify(project_root, ":p"):gsub("/", "\\"):gsub("\\+$", "") .. "\\"

	-- Path of file to be uploaded
	local absolute_filepath = vim.fn.fnamemodify(filepath, ":p"):gsub("/", "\\"):gsub("\\+$", "")

	-- Get relative path
	if not absolute_filepath:find(project_root, 1, true) then
		error("File is not under the project root")
	end
	local relative_path = absolute_filepath:sub(#project_root + 1)
	relative_path = relative_path:gsub("^\\", ""):gsub("\\", "/")

	-- Get remote path and base
	local remote_base = ftp_config.remote_path:gsub("\\", "/"):gsub("/+$", "")
	local remote_path = remote_base .. (remote_base:sub(-1) ~= "/" and "/" or "") .. relative_path

	-- URL-encode password
	local encoded_password = url_encode(ftp_config.password)

	-- Generate command
	local cmd = string.format(
		'winscp.com /command "open %s://%s:%s@%s/" "mkdir %s" "put %s %s" "exit"',
		ftp_config.prefix,
		ftp_config.user,
		encoded_password,
		ftp_config.host,
		remote_base,
		absolute_filepath,
		remote_path
	)

	-- Execute
	local result = os.execute(cmd)
	if result == 0 then
		vim.notify(
			"Success: Uploaded " .. filepath .. " to " .. remote_path,
			vim.log.levels.INFO,
			{ title = "windows-sync" }
		)
	else
		vim.notify("Error: Upload failed. Command: " .. cmd, vim.log.levels.ERROR, { title = "windows-sync" })
	end
end

local function get_config(show_error)
	local ftp_config = get_ftp_config()
	if not ftp_config and show_error then
		vim.notify("Warning: No valid FTP config found", vim.log.levels.WARN, { title = "windows-sync" })
	end
	return ftp_config
end

function module.setup(opts)
	opts = opts or {}

	local ftp_config = get_config(false)
	local active = (ftp_config and ftp_config.active) or 1
	if active == 0 then
		return
	end

	-- On keymap press
	vim.keymap.set("n", opts.keymap or "<Leader>fu", function()
		local ftp_config = get_config()
		if ftp_config then
			upload_file_with_winscp(vim.api.nvim_buf_get_name(0), ftp_config)
		end
	end, { desc = "Upload current file" })

	-- On save
	if opts.auto_upload then
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = vim.api.nvim_create_augroup("FtpAutoUpload", { clear = true }),
			callback = function(args)
				local ftp_config = get_config(false)
				if ftp_config then
					upload_file_with_winscp(vim.api.nvim_buf_get_name(args.buf), ftp_config)
				end
			end,
		})
	end

	-- Command (with parameter)
	vim.api.nvim_create_user_command("Upload", function(opts)
		local filename
		if opts.args == "" then
			filename = vim.api.nvim_buf_get_name(0)
		else
			filename = vim.fn.fnamemodify(opts.args, ":p")
		end

		local ftp_config = get_config()
		if ftp_config then
			upload_file_with_winscp(filename, ftp_config)
		end
	end, { nargs = "?", desc = "Upload current file or specified file via FTP/SFTP" })
end

return module
