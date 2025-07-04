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

local function normalize_path(path)
    return (vim.fn.fnamemodify(path, ":p"):gsub("\\", "/"):gsub("/+$","")):lower()
end

local function upload_file_with_winscp(filepath, ftp_config)
	local project_root = normalize_path(ftp_config.project_root or vim.fn.getcwd())
	local absolute_filepath = normalize_path(filepath)

    -- File needs to be under root path
    if absolute_filepath:sub(1, #project_root) ~= project_root then
		vim.notify("ERROR: File is not under the project root", vim.log.levels.ERROR, { title = "windows-sync" })
        return
	end

	-- Get relative path
	local relative_path = absolute_filepath:sub(#project_root + 2)
	relative_path = relative_path:gsub("\\", "/")

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
			"Success: Uploaded to " .. remote_path,
			vim.log.levels.INFO,
			{ title = "windows-sync" }
		)
	else
		vim.notify("Error: Upload failed.", vim.log.levels.ERROR, { title = "windows-sync" })
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

	-- Command for uploading specific file or directory
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

	-- Command for creating FTP config
	vim.api.nvim_create_user_command("Config", function()
		local project_root = vim.fn.getcwd()
		local file = io.open(project_root .. "/ftp_config.lua", "w")
		if not file then
			vim.notify("Failed to create ftp_config.lua", vim.log.levels.ERROR)
			return
		end
		local config_text = [[
local server = {
    prefix = "ftp",
    host = "",
    user = "",
    password = "",
    remote_path = "",
    project_root = nil
}

return server
]]
		file:write(config_text)
		file:close()
		vim.notify("Created ftp_config.lua in project root", vim.log.levels.INFO)
	end, { desc = "Create ftp_config.lua in project root" })
end

return module
