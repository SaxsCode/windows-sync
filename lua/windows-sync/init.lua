local module = {}

local function get_ftp_config()
	local config_path = vim.fn.getcwd() .. "/ftp_config.lua"
	local ok, config = pcall(dofile, config_path)
	return ok and config or nil
end

local function upload_file_with_winscp(filepath, ftp_config)
	-- Normalize project root
	local project_root = ftp_config.project_root or vim.fn.getcwd()
	project_root = vim.fn.fnamemodify(project_root, ":p")
	project_root = project_root:gsub("\\", "/"):gsub("/$", "")

	-- Get absolute file path and normalize
	local absolute_filepath = vim.fn.fnamemodify(filepath, ":p")
	absolute_filepath = absolute_filepath:gsub("\\", "/")

	-- Calculate relative path
	local relative_path = absolute_filepath:sub(#project_root + 2)

	-- Construct remote path
	local remote_base = ftp_config.remote_path
	remote_base = remote_base:gsub("/$", "") .. "/"
	local remote_path = remote_base .. relative_path

	-- URL-encode special characters in password
	local encoded_password = ftp_config.password:gsub("[%%&]", {
		["%"] = "%25",
		["&"] = "%26",
	})

	-- WinSCP command: create the directory (without trailing slash for mkdir)
	local remote_dir = remote_base:gsub("/$", "")
	local cmd = string.format(
		'winscp.com /command "open ftp://%s:%s@%s/" "mkdir %s" "put \\"%s\\" \\"%s\\"" "exit"',
		ftp_config.user,
		encoded_password,
		ftp_config.host,
		remote_dir,
		absolute_filepath,
		remote_path
	)

	-- Execute command
	local result = os.execute(cmd)
	if result == 0 then
		print("Success: Uploaded " .. filepath .. " to " .. remote_path)
	else
		print("Error: Upload failed. Command: " .. cmd)
	end
end

function module.setup(opts)
	opts = opts or {}
	vim.keymap.set("n", opts.keymap or "<Leader>fu", function()
		local ftp_config = get_ftp_config()
		if ftp_config then
			upload_file_with_winscp(vim.api.nvim_buf_get_name(0), ftp_config)
		else
			print("Error: No valid FTP config found")
		end
	end, { desc = "Upload current file" })

	if opts.auto_upload then
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = vim.api.nvim_create_augroup("FtpAutoUpload", { clear = true }),
			callback = function(args)
				local ftp_config = get_ftp_config()
				if ftp_config then
					upload_file_with_winscp(vim.api.nvim_buf_get_name(args.buf), ftp_config)
				end
			end,
		})
	end
end

return module
