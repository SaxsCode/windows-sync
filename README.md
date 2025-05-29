# windows-sync

A simple Lua plugin for Neovim to upload files to FTP servers, designed specifically for Windows environments.

---

## Features

- Upload the current file to a configured FTP server directly from Neovim using `curl`.
- Fully automated FTP uploads with username and password authentication.
- Easy per-project FTP configuration via a Lua config file.
- Configurable keymap for quick uploads.

---

## Requirements

- **`curl` must be installed and available in your system's PATH.**  
  Windows 10 and later include `curl` by default.  
  For older versions, download it from [https://curl.se/windows/](https://curl.se/windows/).

---

## Installation

Use your favorite plugin manager. For example, with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
return {
  'saxscode/windows-sync',
  opts = {
    keymap = '<Leader>fu', -- Optional, defaults to <Leader>fu
  },
}
```
---

## Configuration

Create a `ftp_config.lua` file in your project root with the following structure:

```lua
return {
    host = "", -- FTP server hostname (no protocol prefix)
    user = "", -- FTP username
    password = "", -- FTP password
    remote_path = "", -- Remote path including filename or directory
}

```

**Note:**  
- The `host` should be just the hostname without `ftp://` or trailing slashes.  
- `remote_path` can be a directory (e.g., `"/"`) or full remote filename (e.g., `"/myfile.txt"`).

---

## Usage

- Open a file in Neovim.
- Press the configured keymap (default `<Leader>fu`) to upload the current file to the remote FTP server.
- The plugin uses `curl` to perform the upload automatically using your FTP credentials.

---

## Todo

- Upload files to correct remote path when inside subfolders.
- Create a command to upload files.
- Allow passing parameters to upload specific files or folders.

---

## Wishlist

- Support multiple FTP servers per project.
- Add a command to generate a default FTP config in the project root.
- Add download functionality from remote server.

---

## Notes and Limitations

- Requires `curl` installed and accessible in your system PATH.
- Passwords are stored in plaintext in the config file — use with caution.
- The plugin is a simple starting point and can be extended with more features and robustness.

---

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to open a pull request or issue on GitHub.

