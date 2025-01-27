#!/bin/bash

# Set home directory absolute path
HOME_DIR="/home/mycochar"

# Install dependencies
sudo apt-get update
sudo apt-get install -y build-essential wget

# Install GCC
cd $HOME_DIR
wget http://ftp.gnu.org/gnu/gcc/gcc-12.2.0/gcc-12.2.0.tar.gz
tar -xzf gcc-12.2.0.tar.gz
cd gcc-12.2.0
./configure --prefix=$HOME_DIR/gcc --disable-multilib
make -j$(nproc)
make install

# Add GCC to the PATH
echo "export PATH=\$HOME_DIR/gcc/bin:\$PATH" >> $HOME_DIR/.bashrc
source $HOME_DIR/.bashrc

# Install Python 3
cd $HOME_DIR
wget https://www.python.org/ftp/python/3.10.4/Python-3.10.4.tgz
tar -xzf Python-3.10.4.tgz
cd Python-3.10.4
./configure --prefix=$HOME_DIR/python3 --enable-optimizations
make -j$(nproc)
make install

# Add Python 3 to the PATH
echo "export PATH=\$HOME_DIR/python3/bin:\$PATH" >> $HOME_DIR/.bashrc
source $HOME_DIR/.bashrc

echo "GCC and Python 3 installation completed!"
