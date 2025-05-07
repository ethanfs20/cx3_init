#!/bin/bash

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root. Use sudo."
   exit 1
fi

echo "🔍 Detecting ConnectX-3 devices..."
CX3_FOUND=$(lspci | grep -i 'Mellanox.*ConnectX-3')

if [[ -z "$CX3_FOUND" ]]; then
    echo "❌ No ConnectX-3 (CX3) devices found."
    exit 1
else
    echo "✅ Found ConnectX-3 device(s):"
    echo "$CX3_FOUND"
fi

echo "📦 Installing RDMA and InfiniBand tools..."
dnf install -y rdma-core infiniband-diags perftest libibverbs-utils

echo "📂 Loading in-tree Mellanox modules..."
modprobe mlx4_core
modprobe mlx4_ib

# Verify modules loaded
echo "🔧 Verifying loaded modules:"
lsmod | grep mlx4

# Show RDMA-capable devices
echo "📡 RDMA devices detected:"
if command -v ibv_devinfo &> /dev/null; then
    ibv_devinfo
else
    echo "⚠️ ibv_devinfo not found even after install — something went wrong."
fi

# Done
echo "✅ Setup complete. Run 'dmesg | grep mlx', 'ibstat', or 'ibping' for further diagnostics."
