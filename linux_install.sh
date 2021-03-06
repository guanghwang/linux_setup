#! /usr/bin/env bash

cd $HOME

if [[ $sudo = 'True' ]]; then
    sudo apt update
    sudo apt upgrade
fi

if [[ $curl = 'True' ]]; then
    sudo apt install curl
fi

if [[ $git = 'True' ]]; then
    sudo apt install git
fi

# Download my dotfiles
cd $HOME
git clone https://github.com/kylebarron/dotfiles.git
cd dotfiles
git submodule update --init --recursive
cd ../

if [[ $git = 'True' ]]; then
    cp dotfiles/git/gitconfig_desktop ~/.gitconfig
fi

if [[ $zsh = 'True' ]]; then
    if [[ $sudo = 'True' ]]; then
        sudo apt install -y zsh
    else
        wget -O zsh.tar.gz https://sourceforge.net/projects/zsh/files/latest/download
        mkdir zsh && tar -xvzf zsh.tar.gz -C zsh --strip-components 1
        cd zsh
        
        ./configure --prefix=$HOME/opt/
        make
        make install
        cd ..
        rm -rf zsh.tar.gz zsh
    fi
fi

if [[ $oh-my-zsh = 'True' ]]; then
    if [[ $sudo = 'True' ]]; then
        sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
    else
        git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
    fi
fi

if [[ $zsh-syntax-highlighting = 'True' ]]; then
    sudo apt install -y zsh-syntax-highlighting
fi

if [[ $materialshell = 'True' ]]; then
    cp ~/dotfiles/zsh/materialshell.zsh-theme ~/.oh-my-zsh/themes/
fi

if [[ $zshrc = 'True' ]]; then
    cp ~/dotfiles/zsh/zshrc_desktop ~/.zshrc
fi

if [[ $bashrc = 'True' ]]; then
    cp ~/dotfiles/bash/bashrc_desktop ~/.bashrc
    if [[ $sudo = 'False' ]]; then
        cat 'exec $HOME/bin/zsh -l' >> ~/.bashrc
    fi
fi

if [[ $ssh-server = 'True' ]]; then
    # Install SSH Server
    sudo apt install -y openssh-server

    # SSH Server for encrypted home folder
    sudo mkdir /etc/ssh/$(whoami)
    sudo chmod 755 /etc/ssh/$(whoami)
    #sudo mv ~/.ssh/authorized_keys /etc/ssh/$(whoami)/authorized_keys
    sudo touch /etc/ssh/$(whoami)/authorized_keys
    sudo chmod 644 /etc/ssh/$(whoami)/authorized_keys
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDqIiTcGgYb0DHwLG+WQXgt7t+pBFYdyO494VFFsv5KFa1g+pqdcvZyPoyVqV2ZT2h5w055gKau+GLbtavyK74GRDJFYBNomuEIXp9RBWTt6/qzpnMKTvmMAKgLTujIrUjtYbVhncUB7mV438FecbnNBQW61jqCkEQQSwUlli94RD3C+qOjnLIe9vrIlvcYbZMZUfCmL7VUQByJlkvfhpiteRzXfpXamuCgQAn8GiE9c9S1EFkqcT/7ECLkJNL8ToNVDU7DieQP1ZIIPy6ktG3EOYAcmJwVQ3kSYJcQqL8cy4PVHrZuLyKefKrqeRaSFs1uA83DpjOCxfSBmmqBMR9kLAdG+rkA+a8/Fjn6BPyab6Kr0Uxy0LJfHGgUGA5hKwZExfLzioSIXH9veHUETOcUhG4fmhCWuRGD2ZW2231R/s9ZVjZrdkzCoIrrcnhN4LrnQb29aP15V3RH6hJhWPG8e+paOfIvW8zQaQoqPf9exGhV+CaPPh3OqLKPU1qSZDjyShb4GxKqCJz3ScKIf+bAi+8T/rvQVsw3gLzc+kD9yLdbX30HIUI5sQdyYZAKVNfpuWgIe9e7Q1DVZP3IeBot5GZyTUave7FpTum4TPxc3vUn5ktz7HRMt03Ff64hV3b5RMJbV8s2zaoMUyid79wNUGU2AZAxOWjnVZuaIzPtXw== kyle@mac.local" | sudo tee --append /etc/ssh/$(whoami)/authorized_keys
    sudo sed -i 's@#AuthorizedKeysFile@AuthorizedKeysFile@g' /etc/ssh/sshd_config
    sudo sed -i 's@%h/.ssh/authorized_keys@/etc/ssh/%u/authorized_keys@g' /etc/ssh/sshd_config
    sudo sed -i 's@#PasswordAuthentication yes@PasswordAuthentication no@g' /etc/ssh/sshd_config
    sudo sed -i 's@LogLevel INFO@LogLevel VERBOSE@g' /etc/ssh/sshd_config
    sudo service ssh restart
fi

if [[ $anaconda3 = 'True' ]]; then
    latest="$(curl https://repo.continuum.io/archive/ | grep -P 'Anaconda3-\d\.\d\.\d-Linux-x86_64' | sed -n 1p | cut -d '"' -f 2)"
    wget 'https://repo.continuum.io/archive/'$latest
    bash Anaconda3-*-Linux-x86_64.sh -b -p ~/opt/anaconda3
    rm Anaconda3-*-Linux-x86_64.sh
    if [[ $sudo = 'True' ]]; then
        sudo apt install -y python3-dev python3-pip
    fi
fi

if [[ $anaconda2 = 'True' ]]; then
    latest="$(curl https://repo.continuum.io/archive/ | grep -P 'Anaconda2-\d\.\d\.\d-Linux-x86_64' | sed -n 1p | cut -d '"' -f 2)"
    wget 'https://repo.continuum.io/archive/'$latest
    bash Anaconda2-*-Linux-x86_64.sh -b -p ~/opt/anaconda2
    rm Anaconda2-*-Linux-x86_64.sh
    if [[ $sudo = 'True' ]]; then
        sudo apt install -y python3-dev python3-pip
    fi
fi

if [[ $mkdocs = 'True' ]]; then
    pip install mkdocs mkdocs-material
fi

if [[ $r = 'True' ]]; then
    sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu xenial/"
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
    sudo apt update
    sudo apt install -y r-base r-base-dev
    sudo chown -R $USER:$USER /usr/local/lib/R/site-library
    # https://stackoverflow.com/questions/29969838/setting-r-libs-avoiding-would-you-like-to-use-a-personal-library-instead
fi

if [[ $r-tidyverse = 'True' ]]; then
    if [[ $sudo = 'True' ]]; then
        sudo chown -R $USER:$USER /usr/local/lib/R/site-library
        sudo apt install -y libcurl4-openssl-dev libssl-dev libxml2-dev
    else
        mkdir -p ~/R/site-library/
        export R_LIBS_USER='~/R/site-library/'
    fi
    Rscript -e "install.packages('tidyverse', repos='https://cran.us.r-project.org')"
fi

if [[ $r-gis = 'True' ]]; then
    # sudo apt -fy install
    # sudo apt install -y libcurl4-openssl-dev libssl-dev libxml2-dev libudunits2-dev gdal-bin libgdal-dev python-software-properties
    # sudo add-apt-repository -y ppa:ubuntugis/ppa
    # sudo apt update
    # sudo apt upgrade -y gdal-bin libgdal-dev
    # Rscript ~/dotfiles/install_packages.R
fi

if [[ $r-all = 'True' ]]; then
    sudo apt -fy install
    sudo apt install -y libcurl4-openssl-dev libssl-dev libxml2-dev libudunits2-dev gdal-bin libgdal-dev python-software-properties
    sudo add-apt-repository -y ppa:ubuntugis/ppa
    sudo apt update
    sudo apt upgrade -y gdal-bin libgdal-dev
    Rscript ~/dotfiles/install_packages.R
fi

if [[ $rstudio-desktop = 'True' ]]; then
    latest="$(curl https://www.rstudio.com/products/rstudio/download/ | grep 'href' | grep -i -E 'rstudio-xenial-1\.[[:digit:]]+\.[[:digit:]]+-amd64\.deb' | cut -d '"' -f 2)"
    if [[ -n "$latest" ]]; then
        wget $latest
    else
        wget https://download1.rstudio.org/rstudio-xenial-1.1.383-amd64.deb
    fi
    sudo apt install -y libjpeg62 libgstreamer0.10-0 libgstreamer-plugins-base0.10-0
    sudo apt -fy install
    sudo dpkg -i rstudio-1*-amd64.deb
    rm rstudio-1*-amd64.deb
    # Replace RStudio settings
    mkdir -p ~/.rstudio-desktop/monitored/user-settings/
    cp dotfiles/rstudio/user-settings ~/.rstudio-desktop/monitored/user-settings/user-settings
fi

if [[ $rstudio-server = 'True' ]]; then
    latest="$(curl https://www.rstudio.com/products/rstudio/download-server/ | grep '$ wget' | grep 'amd64' | grep -o -P 'http.+?(?=</code)')"
    if [[ -n "$latest" ]]; then
        wget $latest
    else
        wget https://download2.rstudio.org/rstudio-server-1.1.383-amd64.deb
    fi
    sudo apt install -y gdebi-core
    sudo gdebi --n rstudio-server-1*amd64.deb
    echo "www-address=127.0.0.1" | sudo tee --append /etc/rstudio/rserver.conf
    sudo rstudio-server start
    rm rstudio-server-1*amd64.deb
fi

if [[ $julia = 'True' ]]; then
    latest="$(curl https://julialang.org/downloads/ | grep 'href' | grep -io -P 'http.+?julia-[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-linux-x86_64.tar.gz(?!\.asc)')"
    if [[ -n "$latest" ]]; then
        wget $latest
    else
        wget https://julialang-s3.julialang.org/bin/linux/x64/0.6/julia-0.6.1-linux-x86_64.tar.gz
    fi
    tar -xzf julia-*-linux-x86_64.tar.gz
    mv julia-*/ ~/opt/julia
    rm julia-*-linux-x86_64.tar.gz
    cd $HOME
fi

if [[ $ijulia = 'True' ]]; then
    ~/opt/julia/bin/julia -e 'Pkg.add("IJulia")'
fi

if [[ $mysql = 'True' ]]; then
    wget https://dev.mysql.com/get/mysql-apt-config_0.8.7-1_all.deb
    sudo dpkg -i mysql-apt-config_0.8.7-1_all.deb
    # Select options
    sudo apt update
    sudo apt install mysql-server
fi

if [[ $postgres = 'True' ]]; then
    sudo touch /etc/apt/sources.list.d/pgdg.list
    echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' | sudo tee --append /etc/apt/sources.list.d/pgdg.list
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    sudo apt update
    sudo apt install postgresql-10
    sudo apt install pgloader
fi

if [[ $postgis = 'True' ]]; then
    sudo add-apt-repository -y ppa:ubuntugis/ppa
    sudo apt update
    sudo apt install postgis
    sudo apt install postgresql-10-postgis-2.4
fi

if [[ $qgis = 'True' ]]; then
    sudo add-apt-repository "deb http://qgis.org/ubuntugis xenial main"
    sudo add-apt-repository "deb-src http://qgis.org/ubuntugis xenial main"
    sudo add-apt-repository "deb http://ppa.launchpad.net/ubuntugis/ubuntugis-unstable/ubuntu xenial main"
    sudo apt-key adv        --keyserver keyserver.ubuntu.com --recv-keys 073D307A618E5811
    sudo apt-key adv        --keyserver keyserver.ubuntu.com --recv-keys 089EBE08314DF160
    sudo apt update
    sudo apt install -y qgis python-qgis qgis-plugin-grass
fi

if [[ $atom = 'True' ]]; then
    wget `curl -s https://api.github.com/repos/atom/atom/releases/latest | grep 'browser_download_url' | grep 'deb' | cut -d '"' -f 4`
    sudo dpkg -i atom-amd64.deb
    rm atom-amd64.deb
    
    mkdir -p ~/.atom
    cp dotfiles/atom/* ~/.atom/
    # Change Atom Icon to atom-material-ui Icon
    sudo cp dotfiles/atom/atom_icon.png /usr/share/pixmaps/atom_material_ui.png
    sudo sed -i 's/Icon=atom/Icon=atom_material_ui/' /usr/share/applications/atom.desktop
fi

if [[ $atom-packages = 'True' ]]; then
    apm install --packages-file "dotfiles/atom/desktop_package_list.txt"
    apm update
fi

if [[ $fira-code = 'True' ]]; then
    mkdir -p ~/.local/share/fonts
    for type in Bold Light Medium Regular Retina; do
        wget -O ~/.local/share/fonts/FiraCode-${type}.ttf \
        "https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-${type}.ttf?raw=true";
    done
    fc-cache -f
fi

if [[ $sublime-text = 'True' ]]; then
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt update
    sudo apt install sublime-text
fi

if [[ $pandoc = 'True' ]]; then
    if [[ $sudo = 'True' ]]; then
        wget `curl -s https://api.github.com/repos/jgm/pandoc/releases/latest | grep 'browser_download_url' | grep 'deb' | cut -d '"' -f 4`
        sudo dpkg -i pandoc-2.*-amd64.deb
    else
        wget `curl -s https://api.github.com/repos/jgm/pandoc/releases/latest | grep 'browser_download_url' | grep '.tar.gz' | cut -d '"' -f 4`
        mkdir pandoc
        tar xvzf pandoc-2.*-linux.tar.gz --strip-components 1 -C pandoc
        mkdir -p ~/bin
        mv pandoc/bin/* ~/bin/
        rm -r pandoc pandoc-2.*-linux.tar.gz
    fi
fi

if [[ $autokey-gtk = 'True' ]]; then
    sudo add-apt-repository ppa:troxor/autokey
    sudo apt update
    sudo apt install -y autokey-gtk
    # mkdir -p ~/.config/autokey/data/Sample\ Scripts/
    # cp dotfiles/autokey/code/run_stata.py          ~/.config/autokey/data/My\ Phrases/run_stata.py
    # cp dotfiles/autokey/code/.run_stata.json       ~/.config/autokey/data/My\ Phrases/.run_stata.json
    # cp dotfiles/autokey/code/run_stata_chunk.py    ~/.config/autokey/data/My\ Phrases/run_stata_chunk.py
    # cp dotfiles/autokey/code/.run_stata_chunk.json ~/.config/autokey/data/My\ Phrases/.run_stata_chunk.json
fi

if [[ $node = 'True' ]]; then
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    sudo apt-get install -y nodejs build-essential
fi

if [[ $google-chrome = 'True' ]]; then
    sudo apt install libappindicator1
    sudo apt -fy install
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    rm google-chrome-stable_current_amd64.deb
fi

if [[ $google-chromedriver = 'True' ]]; then
    #statements
fi

if [[ $google-earth = 'True' ]]; then
    sudo apt install -y lsb-core
    sudo apt -fy install
    wget https://dl.google.com/dl/earth/client/current/google-earth-stable_current_amd64.deb
    sudo dpkg -i google-earth-stable_current_amd64.deb
    rm google-earth-stable_current_amd64.deb
fi

if [[ $tex = 'True' ]]; then
    sudo apt install -y texlive-full
fi

if [[ $texmaker = 'True' ]]; then
    sudo apt install -y texmaker
fi

if [[ $lyx = 'True' ]]; then
    sudo add-apt-repository -y ppa:lyx-devel/release
    sudo apt update
    sudo apt install -y lyx
fi

if [[ $spotify = 'True' ]]; then
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
    echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt update -y
    sudo apt install -y spotify-client
fi

if [[ $gitkraken = 'True' ]]; then
    wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
    sudo dpkg -i gitkraken-amd64.deb
    rm gitkraken-amd64.deb
fi

if [[ $jekyll = 'True' ]]; then
    sudo apt install ruby-full
    sudo gem install jekyll
    sudo gem install bundler
    # Need to run (sudo) bundle install or bundle update in website folder to install other dependent gems.
fi

if [[ $virtualbox = 'True' ]]; then
    wget http://download.virtualbox.org/virtualbox/5.2.2/virtualbox-5.2_5.2.2-119230~Ubuntu~xenial_amd64.deb
    sudo dpkg -i virtualbox-5.*-Ubuntu-xenial_amd64.deb
    rm virtualbox-5.*-Ubuntu-xenial_amd64.deb
    # Download VirtualBox Extension Pack
    wget http://download.virtualbox.org/virtualbox/5.2.2/Oracle_VM_VirtualBox_Extension_Pack-5.2.2-119230.vbox-extpack
    sudo adduser `whoami` vboxusers
fi

### Utilities

if [[ $bash-kernel = 'True' ]]; then
    pip install bash_kernel
    sudo mkdir /usr/local/share/jupyter
    sudo chown $USER:$USER /usr/local/share/jupyter
    python -m bash_kernel.install
fi

if [[ $caprine = 'True' ]]; then
    wget `curl -s https://api.github.com/repos/sindresorhus/caprine/releases/latest | grep 'browser_download_url' | grep 'deb' | cut -d '"' -f 4`
    sudo dpkg -i caprine_*_amd64.deb
    rm caprine_*_amd64.deb
fi

if [[ $compizconfig = 'True' ]]; then
    # Remove Unity App Animations (cause I like hiding the launcher)
    # 1) Install Compiz Settings Manager
    sudo apt install -y compizconfig-settings-manager compiz-plugins-extra
    ccsm
    # 2) Compiz Setting Manager -> Desktop -> Ubuntu Unity Plugin -> Launcher
    # 3) Launch Animation: None
    #    Urgent Animation: None
    #    Hide Animation: Fade Only Dash Blur: No Blur
    # 4) CSM -> Effects 5) Disabled everything except Windows Decoration 6) Installed few unity tweakers and made sure that settings there match ones in CSM. In my case MyUnity still was showing Hide Animation set to Fade and Slide, so I changed it to Fade Only there as well.
    # https://askubuntu.com/a/320734/654313
    #
    # Keyboard shortcut to move window between monitors
    # currently mapped to ctrl + super + alt + left and ctrl + super + alt + right
    # http://www.arj.no/2017/01/03/move-windows-ubuntu/
fi

if [[ $dropbox = 'True' ]]; then
    # MANUAL INSTALLS:
    # Install Dropbox
    sudo apt install python-gpgme
    #cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
    #~/.dropbox-dist/dropboxd
    # Needs manual input to link accounts
fi

if [[ $filezilla = 'True' ]]; then
    sudo apt install -y filezilla
fi

if [[ $flat-plat = 'True' ]]; then
    # Flat plat design
    sudo apt install -y gnome-themes-standard gnome-tweak-tool pixmap
    curl -sL https://github.com/nana-4/Flat-Plat/archive/v20170605.tar.gz | tar xz
    cd Flat-Plat-20170605 && sudo ./install.sh
    # go to gnome-tweak-tool and turn on flat-plat-dark
fi

if [[ $flux ]]; then
    # # Install f.lux
    # sudo apt install git python-appindicator python-xdg python-pexpect python-gconf python-gtk2 python-glade2 libxxf86vm1
    # git clone "https://github.com/xflux-gui/xflux-gui.git"
    # cd xflux-gui
    # python download-xflux.py
    # sudo python setup.py install
    # cd ../
    # rm -rf xflux-gui
fi

if [[ $fuzzy-file-finder = 'True' ]]; then
    cd $HOME
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

if [[ $gtop = 'True' ]]; then
    sudo npm install -g gtop
fi

if [[ $hub = 'True' ]]; then
    wget `curl -s https://api.github.com/repos/github/hub/releases/latest | grep 'browser_download_url' | grep 'linux-amd64' | cut -d '"' -f 4`
    tar -xzvf hub-linux-amd64*.tgz
    cd hub-linux-amd64*
    sudo ./install
    cd ..
    rm -rf hub-linux-amd64*.tgz hub-linux-amd64*
fi

if [[ $jq = 'True' ]]; then
    sudo apt install -y jq
fi

if [[ $keybase = 'True' ]]; then
    # Download and install Keybase but not run
    curl -O https://prerelease.keybase.io/keybase_amd64.deb
    sudo dpkg -i keybase_amd64.deb
    sudo apt-get install -fy
    rm keybase_amd64.deb
    # run_keybase
fi

if [[ $lastpass-cli = 'True' ]]; then
    ## Lastpass CLI
    sudo apt install -y openssl libcurl4-openssl-dev libxml2 libssl-dev libxml2-dev pinentry-curses xclip cmake build-essential pkg-config
    git clone git@github.com:lastpass/lastpass-cli.git
    cd lastpass-cli
    # Note: Make sure your PATH is ok. I encountered an error by having anaconda too high in my PATH
    make
    sudo make install
    cd ..
    rm -rf lastpass-cli

    # link=$(curl -s https://api.github.com/repos/lastpass/lastpass-cli/releases/latest | grep tarball_url | cut -d '"' -f 4)
    # wget $link -O lastpass-cli.tar.gz
    # tar -xvzf lastpass-cli.tar.gz
    # cd lastpass-lastpass-cli-96977ad
    # make
fi

if [[ $libmagick = 'True' ]]; then
    sudo apt install -y libmagick++-dev
fi

if [[ $micro = 'True' ]]; then
    wget `curl -s https://api.github.com/repos/zyedidia/micro/releases/latest | grep 'browser_download_url' | grep 'linux64' | cut -d '"' -f 4`
    tar -xzvf micro-*-linux64.tar.gz
    mv micro-*/micro ~/bin/
    rm -rf micro-*/  micro-*-linux64.tar.gz
    mkdir -p ~/.config/micro
    cp ~/dotfiles/micro/* ~/.config/micro/
fi

if [[ $nitrogen = 'True' ]]; then
    # For having different wallpapers on each monitor
    # https://askubuntu.com/questions/390367/using-different-wallpapers-on-multiple-monitors-gnome-2-compiz
    sudo apt install -y nitrogen
fi

if [[ $openvpn = 'True' ]]; then
    # Install OpenVPN to use PIA
    sudo apt install -y openvpn unzip
    cd /etc/openvpn
    sudo wget https://www.privateinternetaccess.com/openvpn/openvpn.zip
    sudo apt install unzip
    sudo unzip openvpn.zip
    sudo rm openvpn.zip
    sudo touch pass.txt ## Add username and pasword in here manually
    sudo chmod 600 pass.txt
    for filename in *.ovpn
    do
      sudo sed -i 's@auth-user-pass@auth-user-pass pass.txt@g' $filename
    done
fi

if [[ $peek ]]; then
    # https://github.com/phw/peek
    sudo add-apt-repository ppa:peek-developers/stable
    sudo apt update
    sudo apt install peek
fi

if [[ $rclone = 'True' ]]; then
    # Fetch and unpack
    curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip
    unzip rclone-current-linux-amd64.zip
    rm rclone-current-linux-amd64.zip
    cd rclone-*-linux-amd64
    # Copy binary file
    sudo cp rclone /usr/bin/
    sudo chown root:root /usr/bin/rclone
    sudo chmod 755 /usr/bin/rclone
    # Install manpage
    sudo mkdir -p /usr/local/share/man/man1
    sudo cp rclone.1 /usr/local/share/man/man1/
    sudo mandb
    cd $HOME
    rm -r rclone-v1.37-linux-amd64
fi

if [[ $redshift = 'True' ]]; then
    sudo apt install -y redshift
fi

if [[ $ripgrep = 'True' ]]; then
    wget `curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep 'browser_download_url' | grep 'x86_64' | grep 'linux' | cut -d '"' -f 4`
    tar -xvzf ripgrep-*-x86_64-unknown-linux-musl.tar.gz
    mv ripgrep*/rg ~/bin/
    rm -r ripgrep-*-x86_64-unknown-linux-musl.tar.gz ripgrep-*-x86_64-unknown-linux-musl
fi

if [[ $shellcheck = 'True' ]]; then
    sudo apt install -y shellcheck
fi

if [[ $speed-test = 'True' ]]; then
    sudo npm install -g speed-test
fi

if [[ $thefuck = 'True' ]]; then
    pip install thefuck
fi

if [[ $tmux = 'True' ]]; then
    sudo apt install -y tmux
    cp dotfiles/tmux/tmux.conf ~/.tmux.conf
fi

if [[ $tree = 'True' ]]; then
    sudo apt install -y tree
fi

if [[ $vlc = 'True' ]]; then
    sudo apt install -y vlc
fi

if [[ $xclip = 'True' ]]; then
    if [[ $sudo = 'True' ]]; then
        sudo apt install -y xclip
    else
        # yum install -y automake autoconf git libXmu libXmu-devel libtool
        git clone https://github.com/astrand/xclip.git
        cd xclip
        autoreconf
        ./configure --prefix=$HOME/opt/
        make
        make install
        make install.man
        cd ..
        rm -rf xclip
    fi
fi

if [[ $xsv = 'True' ]]; then
    wget `curl -s https://api.github.com/repos/BurntSushi/xsv/releases/latest | grep 'browser_download_url' | grep 'x86_64' | grep 'linux' | cut -d '"' -f 4`
    tar -xvzf xsv-*-x86_64-unknown-linux-musl.tar.gz
    mv xsv ~/bin/
    rm xsv-*-x86_64-unknown-linux-musl.tar.gz
fi

if [[ $docker = 'True' ]]; then
    # Install Docker
    sudo apt update
    sudo apt install apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"
    sudo apt update
    sudo apt install docker-ce
    sudo docker run hello-world
fi

if [[ $cuda ]]; then
    # Install CUDA
    wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64-deb
    mv cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64-deb cuda.deb
    sudo dpkg -i cuda.deb
    sudo apt update
    sudo apt install -y cuda
    echo 'export PATH="/usr/local/cuda-8.0/bin:$PATH"' >> ~/.zshrc
    echo 'export LD_LIBRARY_PATH="/usr/local/cuda-8.0/lib64:LD_LIBRARY_PATH"' >> ~/.zshrc
    rm cuda.deb
    nvcc -V
    # compile examples:
    # cd /usr/local/cuda-8.0/samples
    # sudo make
    # cd bin
fi
