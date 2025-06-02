# windows-sync

A simple Lua plugin for Neovim to upload files to FTP servers, designed specifically for Windows environments.

---

## Features

- **Upload the current file to a configured FTP server directly from Neovim using WinSCP.**
- **Automatic remote directory creation**
- **Fully automated FTP uploads with username and password authentication.**
- **Easy per-project FTP configuration via a Lua config file.**
- **Configurable keymap for quick uploads.**
- **Optional auto-upload on save.**

---

## Requirements

- **WinSCP must be installed and available in your system's PATH.**
  - Download WinSCP from [https://winscp.net/eng/download.php](https://winscp.net/eng/download.php).
  - For best results, add WinSCP to your system PATH during installation.
- **Neovim (latest stable version recommended).**

---

## Installation

Use your favorite plugin manager. For example, with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
return {
    'saxscode/windows-sync',
    opts = {
        keymap = '<Leader>fu', -- Optional, defaults to <Leader>fu
        auto_upload = false, -- Set to true to enable auto-upload on save
    },
}
```

---

## Configuration

Create a `ftp_config.lua` file in your project root with the following structure:

```lua
return {
    prefix = "ftp" -- or sftp
    host = "", 
    user = "",
    password = "",
    remote_path = "",
    project_root = nil -- If nil, use config directory as root
}
```

**Note:**  
- The `host` should be just the hostname without `ftp://` or trailing slashes.  
- `remote_path` can be a directory (e.g., `"/"`) or full remote filename (e.g., `"/myfile.txt"`).
- `project_root` can be set to a subfolder of your project to control which local paths are mirrored remotely.

---

## Usage

- **Open a file in Neovim.**
- **Press the configured keymap (default `<Leader>fu`)** to upload the current file to the remote FTP server.
- **Enable auto-upload on save** by setting `auto_upload = true` in your plugin configuration.
  - This will automatically upload the file every time you save it (`:w`).
- **The plugin uses WinSCP to perform the upload and create remote directories as needed.**

---

## Wishlist

- Support multiple FTP servers per project.
- Add a command to generate a default FTP config in the project root.
- Add download functionality from remote server.
- Create a command to upload files.
- Allow passing parameters to upload specific files or folders.
- Configure SFTP per project

---

## Notes and Limitations

- **Requires WinSCP installed and accessible in your system PATH.**
- **Passwords are stored in plaintext in the config file — use with caution.**
- **Auto-upload on save can be enabled or disabled in the plugin configuration.**
- **The plugin is a simple starting point and can be extended with more features and robustness.**

---

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to open a pull request or issue on GitHub.

---

## License

MIT License

---

## Acknowledgments

Inspired by common FTP upload workflows and Neovim plugin best practices.  
Thanks to the Neovim community for guidance and support.
