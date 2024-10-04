all: install_packages copy_nvim copy_alacritty copy_tmux copy_bashrc copy_i3 


install_packages:
	@echo "Installing packages..."
	yay -S --noconfirm nvim alacritty tmux vlc nodejs npm  
	
copy_nvim:
	@echo "Copying nvim to ~/.config/ dir .."
	@cp -r nvim/ ~/.config/  
	@echo "Copied nvim sucessfully ..."

copy_alacritty:
	@echo "Copying alacritty to ~/.config/dir .."
	@cp -r alacritty/ ~/.config/
	@echo "Copied alacritty sucessfully"

copy_tmux:
	@echo "copying tmux to ~/ .."
	@cp -r .tmux/ ~/  
	@cp .tmux.conf ~/  
	@echo "copied tmux sucessfully"

copy_bashrc:
	@echo "copying bashrc to ~/ .."
	@cp .bashrc ~/  
	@echo "copied bashrc sucessfully"

copy_i3:
	@echo "copying i3 to ~/.config/ .."
	@cp -r i3/ ~/.config/  
	@echo "copied i3 sucessfully"

