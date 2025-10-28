#!/bin/bash
set -e

# ==========================================================
#  Fully Portable Certificate Builder (PQC + RSA)
#  Generates .p12 certificates for browser installation
# ==========================================================

# ----- Configuration -----
INSTALL_DIR="$HOME/oqs-local"        # Local installation path for OQS/OpenSSL
BUILD_DIR="$HOME/pqc_build"          # Folder for building certificates
THREADS=$(nproc)
# --------------------------

# ----- Create build directories -----
mkdir -p "$BUILD_DIR"
mkdir -p "$INSTALL_DIR"
mkdir -p "$BUILD_DIR/certs"

# ----- Dependencies -----
sudo apt update
sudo apt install -y git cmake ninja-build build-essential perl pkg-config libssl-dev wget

# ----- Build liboqs if not exists -----
if [ ! -d "$BUILD_DIR/liboqs" ]; then
  echo "=== Cloning liboqs ==="
  git clone --depth 1 --branch main https://github.com/open-quantum-safe/liboqs.git /root/pqc_build/liboqs "$BUILD_DIR/liboqs"
fi

cd "$BUILD_DIR/liboqs"
mkdir -p build && cd build
cmake -GNinja -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" -DBUILD_SHARED_LIBS=ON -DOQS_BUILD_ONLY_LIB=ON ..
ninja -j"$THREADS"
ninja install

# ----- Build oqs-provider for OpenSSL -----
if [ ! -d "$BUILD_DIR/oqs-provider" ]; then
  echo "=== Cloning oqs-provider ==="
  git clone --branch main https://github.com/open-quantum-safe/oqs-provider.git "$BUILD_DIR/oqs-provider"
fi

cd "$BUILD_DIR/oqs-provider"
mkdir -p build && cd build
cmake -GNinja -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
      -DOPENSSL_ROOT_DIR=/usr \
      -DOQS_PROVIDER_BUILD_STATIC=OFF ..
ninja -j"$THREADS"
ninja install
# ----- Environment setup -----
export OPENSSL_MODULES="$INSTALL_DIR/lib/ossl-modules"
export LD_LIBRARY_PATH="$INSTALL_DIR/lib:$LD_LIBRARY_PATH"

# ----- Check OQS provider -----
"$INSTALL_DIR/bin/openssl" list -provider oqsprovider -public-key-algorithms || true

# ==========================================================
#                  User Choice Menu
# ==========================================================
echo "==============================================="
echo " Choose encryption type:"
echo " 1) PQC (Kyber768)"
echo " 2) RSA (2048-bit)"
echo " 3) Hybrid (RSA + PQC)"
echo " 4) Verify connection between two devices"
echo "==============================================="
read -rp "Enter choice [1-4]: " choice

# ----- PQC (Kyber768) -----
if [ "$choice" == "1" ]; then
  echo "=== Generating PQC (Kyber) certificate ==="
  cd "$BUILD_DIR/certs"
  "$INSTALL_DIR/bin/openssl" genpkey -provider oqsprovider -algorithm kyber768 -out kyber.key
  "$INSTALL_DIR/bin/openssl" req -new -x509 -provider oqsprovider -key kyber.key -out kyber.crt -days 365 -subj "/CN=Kyber Device/O=MyOrg"
  "$INSTALL_DIR/bin/openssl" pkcs12 -export -inkey kyber.key -in kyber.crt -name "Kyber Device" -out kyber_device.p12 -passout pass:1234

  echo "✅ PQC certificate generated!"
  echo "Certificates in: $BUILD_DIR/certs/kyber_device.p12 (Password: 1234)"

# ----- RSA (2048-bit) -----
elif [ "$choice" == "2" ]; then
  echo "=== Generating RSA certificate ==="
  cd "$BUILD_DIR/certs"
  openssl genrsa -out rsa.key 2048
  openssl req -new -x509 -key rsa.key -out rsa.crt -days 365 -subj "/CN=RSA Device/O=MyOrg"
  openssl pkcs12 -export -inkey rsa.key -in rsa.crt -name "RSA Device" -out rsa_device.p12 -passout pass:1234

  echo "✅ RSA certificate generated!"
  echo "Certificates in: $BUILD_DIR/certs/rsa_device.p12 (Password: 1234)"

# ----- Hybrid (RSA + PQC) -----
elif [ "$choice" == "3" ]; then
  echo "=== Generating Hybrid (RSA + Kyber) certificate ==="
  cd "$BUILD_DIR/certs"
  
  # Generate RSA
  openssl genrsa -out rsa.key 2048
  openssl req -new -x509 -key rsa.key -out rsa.crt -days 365 -subj "/CN=Hybrid Device/O=MyOrg"
  
  # Generate Kyber
  "$INSTALL_DIR/bin/openssl" genpkey -provider oqsprovider -algorithm kyber768 -out kyber.key
  "$INSTALL_DIR/bin/openssl" req -new -x509 -provider oqsprovider -key kyber.key -out kyber.crt -days 365 -subj "/CN=Hybrid Device/O=MyOrg"
  
  # Merge into PKCS#12
  "$INSTALL_DIR/bin/openssl" pkcs12 -export -inkey rsa.key -in rsa.crt -certfile kyber.crt -name "Hybrid Device" -out hybrid_device.p12 -passout pass:1234

  echo "✅ Hybrid certificate generated!"
  echo "Certificates in: $BUILD_DIR/certs/hybrid_device.p12 (Password: 1234)"

# ----- Verify connection placeholder -----
elif [ "$choice" == "4" ]; then
  echo "🔹 Verification feature not implemented yet."
  echo "This would test connection between two devices using the chosen certificates."

else
  echo "❌ Invalid choice. Please run again and select 1, 2, 3, or 4."
  exit 1
fi

echo "==============================================="
echo " All done! Import the .p12 file into your browser."
echo "==============================================="


