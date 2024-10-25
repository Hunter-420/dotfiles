all: install_packages copy_nvim copy_alacritty copy_tmux copy_bashrc copy_i3 copy_wall i3 


install_packages:
	@echo "Installing packages..."
	yay -S --noconfirm neovim alacritty tmux vlc nodejs npm picom nvim-packer-git xclip neofetch feh bumblebee-status brightnessctl networkmanager-git ranger
	
copy_nvim:
	@echo "Copying nvim to ~/.config/ dir .."
	@cp -rf nvim/ ~/.config/  
	@echo "Copied nvim sucessfully ..."

copy_alacritty:
	@echo "Copying alacritty to ~/.config/dir .."
	@cp -rf alacritty/ ~/.config/
	picom -b
	@echo "Copied alacritty sucessfully"

copy_tmux:
	@echo "copying tmux to ~/ .."
	@cp -rf .tmux/ ~/  
	@cp -f .tmux.conf ~/  
	@echo "copied tmux sucessfully"

copy_bashrc:
	@echo "copying bashrc to ~/ .."
	@cp -f .bashrc ~/  
	@echo "copied bashrc sucessfully"

copy_i3:
	@echo "copying i3 to ~/.config/ .."
	@cp -rf i3/ ~/.config/  
	@echo "copied i3 sucessfully"

copy_wall:
	@echo "copying wall tp ~/Pictures/wall/ .."
	@mkdir -p ~/Pictures/wall/
	@cp -rf wall/ ~/Pictures/wall/
	@echo "copid wall sucessfully"
