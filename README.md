🧩 PQC + Classical Certificate Demo

This project demonstrates how to generate Post-Quantum Cryptography (PQC), RSA, and Hybrid (RSA + PQC) certificates using the Open Quantum Safe (OQS) provider with OpenSSL.
It also explains how to import these certificates into browsers and verify the OQS provider setup.

⚙️ Tool Architecture and Implementation
Directory Structure
$HOME/pqc_build/
├── certs/               # Generated certificates (.key, .crt, .p12)
├── liboqs/              # liboqs source (if cloned for building)
├── oqs-provider/        # OQS OpenSSL provider source
└── openssl/             # Custom OpenSSL source (optional)

$HOME/oqs-local/
├── bin/                 # Custom OpenSSL binary
├── lib/                 # Shared libraries, including liboqs
└── lib/ossl-modules/    # OpenSSL provider module (.so)

How It Works

Environment Setup

LD_LIBRARY_PATH → Points to liboqs installation path.

OPENSSL_MODULES → Points to the oqsprovider.so shared library.

Custom OpenSSL

Uses the binary: $INSTALL_DIR/bin/openssl

Compiled with OQS provider support to generate PQC keys.

Certificate Generation

PQC (Kyber768): Uses OQS provider.

RSA (2048-bit): Uses standard OpenSSL.

Hybrid: Combines both RSA and PQC into a PKCS#12 (.p12) file.

PKCS#12 Export

Stores private key + certificate.

Password-protected for secure import into browsers or devices.

🧱 Dependencies and Requirements
Dependency	Purpose
OpenSSL ≥ 3.5.3	Required for OQS provider support
liboqs	Provides PQC algorithms (e.g., Kyber768)
oqs-provider	OpenSSL provider enabling PQC algorithms
CMake & Ninja	Required to build dependencies
Git	For cloning source repositories
🪜 Installation and Setup
1. Prerequisites
sudo apt update
sudo apt install -y build-essential cmake ninja-build git pkg-config libssl-dev

2. Clone and Build Dependencies
mkdir -p ~/pqc_build
cd ~/pqc_build

# Clone liboqs
git clone --depth 1 https://github.com/open-quantum-safe/liboqs.git
cd liboqs
mkdir build && cd build
cmake -GNinja -DCMAKE_INSTALL_PREFIX=~/oqs-local -DBUILD_SHARED_LIBS=ON -DOQS_BUILD_ONLY_LIB=ON ..
ninja -j$(nproc)
ninja install

# Clone OQS OpenSSL provider
cd ~/pqc_build
git clone --depth 1 https://github.com/open-quantum-safe/oqs-provider.git
cd oqs-provider
mkdir build && cd build
cmake -GNinja -DCMAKE_INSTALL_PREFIX=~/oqs-local -DOPENSSL_ROOT_DIR=/usr ..
ninja -j$(nproc)
ninja install

# Optional: Build OpenSSL (for full control)
cd ~/pqc_build
git clone --branch openssl-3.5.3 https://github.com/openssl/openssl.git
cd openssl
./Configure --prefix=~/oqs-local --openssldir=~/oqs-local enable-ossl-shared
make -j$(nproc)
make install

🧩 How to Use the Tool
1. Run the Script
chmod +x safe_pqc_build.sh
./safe_pqc_build.sh

2. Menu Options
Option	Description
1	Generate PQC (Kyber768) certificate
2	Generate RSA (2048-bit) certificate
3	Generate Hybrid (RSA + PQC) certificate
4	Verify OQS provider and supported algorithms
3. Output Files

Certificates are stored in:
~/pqc_build/certs/

File	Description
kyber_device.p12	PQC certificate
rsa_device.p12	RSA certificate
hybrid_device.p12	Hybrid certificate

Default password: 1234

🌐 Using Certificates in Browsers
Chrome / Edge

Open chrome://settings/certificates

Click Import

Select .p12 file

Enter password 1234

Finish the import wizard

Firefox

Go to Settings → Privacy & Security → Certificates → View Certificates

Click Import

Select .p12 file

Enter password 1234

Certificate will now appear in the manager

💡 Hybrid certificates allow negotiation of either RSA or PQC-based TLS depending on server support.

🔍 Verification

To verify that the OQS provider is available:

export OPENSSL_MODULES=~/oqs-local/lib/ossl-modules
~/oqs-local/bin/openssl list -provider oqsprovider -public-key-algorithms


Expected output includes:

Kyber512
Kyber768
Kyber1024

📚 References

Open Quantum Safe Project

liboqs GitHub Repository

oqs-provider GitHub Repository
