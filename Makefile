all: install_packages enable_services update_config restart_services migrate_packages copy_nvim copy_alacritty copy_tmux copy_bashrc copy_i3 copy_wall sync_packer

install_git_packages:
	@echo "Installing git packages..."
	
	# Check if yay is installed
	@if ! pacman -Q yay &>/dev/null; then \
		echo "Installing git and base-devel if needed..."; \
		sudo pacman -S --needed --noconfirm git base-devel; \
		echo "Cloning yay repository..."; \
		git clone https://aur.archlinux.org/yay.git; \
		cd yay && makepkg -si --noconfirm; \
		cd .. && rm -rf yay; \
		echo "Installed yay successfully."; \
	else \
		echo "yay is already installed, skipping."; \
	fi
	
	# Cloning copilot.vim repository if not already cloned
	@if [ ! -d "~/.vim/pack/github/start/copilot.vim" ]; then \
		echo "Cloning copilot.vim repository..."; \
		git clone https://github.com/github/copilot.vim.git ~/.vim/pack/github/start/copilot.vim; \
		echo "Cloned copilot.vim repository successfully."; \
	else \
		echo "copilot.vim is already installed, skipping."; \
	fi
	
	@echo "Git packages installed successfully."

install_packages:
	@echo "Installing packages..."
	@for pkg in xorg-xrandr pavucontrol ttf-ubuntu-mono-nerd ttf-ubuntu-nerd libinput-gestures discord postman lens-bin telegram-desktop-bin podman chromium neovim alacritty tmux vlc nodejs npm picom nvim-packer-git xclip neofetch feh bumblebee-status brightnessctl git ranger dmenu dunst transmission-qt maim; do \
		if ! pacman -Q $$pkg &>/dev/null; then \
			yay -S --noconfirm $$pkg; \
			echo "Installed $$pkg"; \
		else \
			echo "$$pkg is already installed, skipping."; \
		fi \
	done

	@echo "Installing packages for VM ..."
	@for pkg in doctl kubectl i3-wm i3blocks i3lock qemu-full virt-manager virt-viewer dnsmasq bridge-utils libguestfs ebtables vde2 openbsd-netcat; do \
		if ! pacman -Q $$pkg &>/dev/null; then \
			sudo pacman -S --noconfirm $$pkg; \
			echo "Installed $$pkg"; \
		else \
			echo "$$pkg is already installed, skipping."; \
		fi \
	done
	@echo "All packages installed successfully."

enable_services:
	@echo "Enabling services ..."
	sudo systemctl start libvirtd.service
	sudo systemctl enable libvirtd.service

update_config:
	@echo "Updating /etc/libvirt/libvirtd.conf..."
	@sudo sed -i 's/^#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf
	@sudo sed -i 's/^#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf
	@echo "Configuration updated successfully!"

restart_services:
	@echo "Restarting services ..."
	sudo systemctl restart libvirtd.service
	@echo "Services restarted successfully!"

migrate_packages:
	@echo "Migrating packages ..."
	@echo "Migrate alacritty config ..."
	@alacritty migrate

install_themes:
	@echo "Installing alacritty-themes..."
	@npm install -g alacritty-themes
	@echo "alacritty-themes installed successfully!"

copy_nvim:
	@echo "Copying nvim to ~/.config/ dir .."
	@cp -rf nvim/ ~/.config/  
	@echo "Copied nvim successfully ..."

copy_alacritty:
	@echo "Copying alacritty to ~/.config/dir .."
	@cp -rf alacritty/ ~/.config/
	@if ! pgrep -x "picom" > /dev/null; then \
		echo "Starting picom..."; \
		picom -b; \
	else \
		echo "Picom is already running, skipping."; \
	fi
	@echo "Copied alacritty successfully"


copy_tmux:
	@echo "Copying tmux to ~/ .."
	@cp -rf .tmux/ ~/  
	@cp -f .tmux.conf ~/  
	@echo "Copied tmux successfully"

copy_bashrc:
	@echo "Copying bashrc to ~/ .."
	@cp -f .bashrc ~/  
	@echo "Copied bashrc successfully"

copy_i3:
	@echo "Copying i3 to ~/.config/ .."
	@cp -rf i3/ ~/.config/  
	@echo "Copied i3 successfully"

copy_wall:
	@echo "Copying wall to ~/Pictures/wall/ .."
	@mkdir -p ~/Pictures/wall/
	@cp -rf wall/ ~/Pictures/wall/
	@echo "Copied wall successfully"

sync_packer:
	@echo "Opening packer.lua, sourcing it, and running PackerSync..."
	@nvim -c "edit ~/.config/nvim/lua/archguy/packer.lua" -c "so" -c "PackerSync" -c "qa"
	@echo "PackerSync completed successfully!"
