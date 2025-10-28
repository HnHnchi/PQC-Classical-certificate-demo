# 🧩 PQC + Classical Certificate Demo  
> A hybrid certificate generation and management tool combining **Post-Quantum Cryptography (PQC)** and **RSA** — built with the **Open Quantum Safe (OQS)** provider for OpenSSL.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![OpenSSL](https://img.shields.io/badge/OpenSSL-3.5.3+-blue.svg)](https://www.openssl.org)
[![liboqs](https://img.shields.io/badge/liboqs-Latest-orange.svg)](https://github.com/open-quantum-safe/liboqs)
[![Made With](https://img.shields.io/badge/Made%20with-Bash-yellow.svg)]()

---

## ⚙️ Overview

This project demonstrates how to generate **PQC**, **RSA**, and **Hybrid (RSA + PQC)** certificates using the **OQS provider** with a custom OpenSSL build.  
It also shows how to import these certificates into browsers and verify PQC algorithm support.

---

## 🧱 Directory Structure

$HOME/pqc_build/
├── certs/ # Generated certificates (.key, .crt, .p12)
├── liboqs/ # liboqs source (if cloned for building)
├── oqs-provider/ # OQS OpenSSL provider source
└── openssl/ # Custom OpenSSL source (optional)

$HOME/oqs-local/
├── bin/ # Custom OpenSSL binary
├── lib/ # Shared libraries, including liboqs
└── lib/ossl-modules/ # OpenSSL provider module (.so)

---

## 🧩 How It Works

1. **Environment Setup**
   - `LD_LIBRARY_PATH` → Points to the local liboqs installation.  
   - `OPENSSL_MODULES` → Points to the directory containing `oqsprovider.so`.

2. **Custom OpenSSL Invocation**
   - Uses `$INSTALL_DIR/bin/openssl` (OQS-enabled build).  
   - Supports PQC key generation using the OQS provider.

3. **Certificate Generation**
   - **PQC (Kyber768)** — via OQS provider  
   - **RSA (2048-bit)** — via standard OpenSSL routines  
   - **Hybrid** — combines RSA + PQC into one `.p12` file

4. **PKCS#12 Export**
   - Stores private key + certificate securely.  
   - Password-protected for browser/device installation.

---

## 📦 Dependencies and Requirements

| Dependency | Purpose |
|-------------|----------|
| **OpenSSL ≥ 3.5.3** | Required for PQC/OQS support |
| **liboqs** | Implements PQC algorithms (e.g., Kyber768) |
| **oqs-provider** | Integrates PQC algorithms into OpenSSL |
| **CMake & Ninja** | Build system for libraries |
| **Git** | To clone repositories |

---

## 🚀 Installation and Setup

### 1️⃣ Prerequisites

```bash
sudo apt update
sudo apt install -y build-essential cmake ninja-build git pkg-config libssl-dev
mkdir -p ~/pqc_build
cd ~/pqc_build

# Clone liboqs
git clone --depth 1 https://github.com/open-quantum-safe/liboqs.git
cd liboqs
mkdir build && cd build
cmake -GNinja -DCMAKE_INSTALL_PREFIX=~/oqs-local -DBUILD_SHARED_LIBS=ON -DOQS_BUILD_ONLY_LIB=ON ..
ninja -j$(nproc)
ninja install

# Clone OQS provider
cd ~/pqc_build
git clone --depth 1 https://github.com/open-quantum-safe/oqs-provider.git
cd oqs-provider
mkdir build && cd build
cmake -GNinja -DCMAKE_INSTALL_PREFIX=~/oqs-local -DOPENSSL_ROOT_DIR=/usr ..
ninja -j$(nproc)
ninja install

# (Optional) Build OpenSSL 3.5.3+
cd ~/pqc_build
git clone --branch openssl-3.5.3 https://github.com/openssl/openssl.git
cd openssl
./Configure --prefix=~/oqs-local --openssldir=~/oqs-local enable-ossl-shared
make -j$(nproc)
make install
chmod +x safe_pqc_build.sh
./safe_pqc_build.sh
```
🌐 Importing Certificates into Browsers
🧭 Chrome / Edge

Open chrome://settings/certificates

Click Import

Select .p12 file and enter password 1234

Finish the import wizard

🦊 Firefox

Open Settings → Privacy & Security → Certificates → View Certificates

Click Import

Select .p12 file and enter password 1234

Certificate will appear in the Authorities or Your Certificates tab

💡 Hybrid certificates enable browsers to negotiate either RSA or PQC-based TLS, depending on the server’s capabilities.
