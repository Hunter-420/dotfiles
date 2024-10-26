# Dotfiles README

Welcome to my dotfiles repository! This setup is designed for a smooth and efficient development experience on Arch Linux. Below you'll find all the necessary information to get started with this configuration.

## System Information

```bash
                  -`                    rusty@archlinux
                 .o+`                   ---------------
                `ooo/                   OS: Arch Linux x86_64
               `+oooo:                  Host: K401LB 1.0
              `+oooooo:                 Kernel: 6.11.1-arch1-1
              -+oooooo+:                Uptime: 23 hours, 8 mins
            `/:-:++oooo+:               Packages: 1042 (pacman)
           `/++++/+++++++:              Shell: bash 5.2.37
          `/++++++++++++++:             Resolution: 1920x1080
         `/+++ooooooooooooo/`           WM: i3
        ./ooosssso++osssssso+`          Theme: Adwaita [GTK3]
       .oossssso-````/ossssss+`         Icons: Adwaita [GTK3]
      -osssssso.      :ssssssso.        Terminal: alacritty
     :osssssss/        osssso+++.       CPU: Intel i7-5500U (4) @ 3.000GHz
    /ossssssss/        +ssssooo/-       GPU: Intel HD Graphics 5500
   `/ossssso+/:-        -:/+osssso+-     GPU: NVIDIA GeForce 940M
  `+sso+:-`                 `.-/+oso:    Memory: 2860MiB / 7837MiB
 `++:.                           `-/+/
 .`                                 `/
```

## Setup Instructions

To set up the dotfiles, follow these steps:

1. **Clone this repository**:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git
   cd dotfiles
   ```

2. **Run the Makefile**:
   The setup can be automated using the Makefile. Simply run:
   ```bash
   make all
   ```

   This command will:
   - Install necessary packages.
   - Copy configuration files to their respective directories.

### Final Steps for Neovim

After running the Makefile:

1. Navigate to the configuration file of plugins:
   ```bash
    cd ~/.config/nvim/lua/archguy/
   ```
   
2. Open packer.lua on Neovim and run:
   ```vim
   :so
   :PackerSync
   ```

### Tmux Shortcuts in .bashrc

- **`tmka`**: Kill all Tmux sessions.
- **`tmls`**: List all Tmux sessions.
- **`tmns <session_name>`**: Create a new Tmux session with the specified name.
- **`tmas <session_name>`**: Attach to an existing Tmux session by name.
- **`tmks <session_name>`**: Kill a specific Tmux session by name.
- **`tml`**: Alias for listing Tmux sessions.


## Inspirations

The Neovim configuration is inspired by [ThePrimeagen](https://github.com/theprimeagen).

## Contributing

Feel free to fork this repository and make it your own! If you have any suggestions or improvements, please create a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.

Enjoy your setup! 🚀
