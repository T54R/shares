#!/bin/bash

# Exit on errors
set -e

# Variables
GCC_VERSION="12.3.0"
GCC_TAR="gcc-$GCC_VERSION.tar.gz"
GCC_URL="http://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/$GCC_TAR"
GCC_DIR="gcc-$GCC_VERSION"
INSTALL_DIR="$HOME/localgcc"
PYTHON_VERSION="3.11.6"
PYTHON_TAR="Python-$PYTHON_VERSION.tgz"
PYTHON_URL="https://www.python.org/ftp/python/$PYTHON_VERSION/$PYTHON_TAR"
PYTHON_DIR="Python-$PYTHON_VERSION"

# Step 1: Download and build GCC locally
echo "Downloading GCC $GCC_VERSION..."
wget -q $GCC_URL -O $GCC_TAR
echo "Extracting GCC..."
tar -xf $GCC_TAR
cd $GCC_DIR

echo "Downloading GCC prerequisites..."
./contrib/download_prerequisites

echo "Creating build directory for GCC..."
mkdir -p build && cd build

echo "Configuring GCC..."
../configure --prefix=$INSTALL_DIR --disable-multilib --enable-languages=c,c++

echo "Building GCC... (this may take a while)"
make -j$(nproc)

echo "Installing GCC locally..."
make install

# Step 2: Add GCC to PATH
echo "Adding GCC to PATH..."
echo "export PATH=$INSTALL_DIR/bin:\$PATH" >> ~/.bashrc
export PATH=$INSTALL_DIR/bin:$PATH
cd ../..
echo "GCC installed successfully!"

# Step 3: Download and build Python locally
echo "Downloading Python $PYTHON_VERSION..."
wget -q $PYTHON_URL -O $PYTHON_TAR
echo "Extracting Python..."
tar -xf $PYTHON_TAR
cd $PYTHON_DIR

echo "Configuring Python..."
./configure --prefix=$HOME/localpython --enable-optimizations

echo "Building Python..."
make -j$(nproc)

echo "Installing Python locally..."
make install

# Step 4: Add Python to PATH
echo "Adding Python to PATH..."
echo "export PATH=$HOME/localpython/bin:\$PATH" >> ~/.bashrc
export PATH=$HOME/localpython/bin:$PATH

# Step 5: Verify installation
echo "Verifying installations..."
gcc --version
python3 --version

echo "Installation completed! Please run 'source ~/.bashrc' to finalize."
