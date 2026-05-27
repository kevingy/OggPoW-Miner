
# 🪨 OggMiner

> Custom GPU miner for Oggchain. Built on OggPoW — a custom Go implementation of ProgPoW.

**OggMiner** is a GPU mining worker built specifically for the Oggchain network. It is forked from [progminer](https://github.com/hydnoracoin/progminer) and adjusted to work with **OggPoW** — Oggchain's custom ProgPoW implementation written in Go.

With OggMiner you can mine OGG on Oggchain through solo mining directly to your node, or through the official OGG mining pool.

Forked from [progminer](https://github.com/hydnoracoin/progminer), which originates from [ethminer](https://github.com/ethereum-mining/ethminer). You can also check the original [ProgPoW](https://github.com/ifdefelse/progpow) implementation and [EIP-1057](https://eips.ethereum.org/EIPS/eip-1057) for the specification.

---

## ⛏️ Features

- GPU mining for Oggchain
- OggPoW support — custom ProgPoW implementation
- NVIDIA CUDA mining
- AMD OpenCL mining
- Windows builds
- Linux builds
- Solo mining directly to an Oggchain node via RPC
- Pool mining through the official OGG mining pool
- On-GPU DAG generation
- Realistic benchmarking against arbitrary epoch / DAG / block number
- ASIC resistant — GPU focused from block one

---

## 🖥️ Supported GPU Builds

OggMiner is released in separate builds depending on GPU backend and operating system.

| Build | Backend | Intended For |
|---|---|---|
| Windows NVIDIA | CUDA | NVIDIA GPUs |
| Windows AMD | OpenCL | AMD GPUs |
| Linux NVIDIA | CUDA | NVIDIA GPUs |
| Linux AMD | OpenCL | AMD GPUs |

Use the **CUDA build** for NVIDIA cards.  
Use the **OpenCL build** for AMD cards.

---

## 🟢 NVIDIA CUDA Support

The NVIDIA build is compiled with **CUDA 13.2**.

Supported CUDA architectures include:

| Architecture | GPU Family |
|---|---|
| `sm_70` | Volta |
| `sm_75` | Turing / RTX 20 Series |
| `sm_80` | Ampere Datacenter |
| `sm_86` | RTX 30 Series |
| `sm_89` | RTX 40 Series |
| `sm_90` | Hopper / newer NVIDIA pro GPUs |
| `sm_120` | Blackwell / RTX 50 Series |
| `compute_120` | PTX fallback for future NVIDIA compatibility |

### NVIDIA GPU Support

This build is intended for:

- RTX 20 Series
- RTX 30 Series
- RTX 40 Series
- RTX 50 Series

RTX 60 readiness is included through PTX fallback, but full native RTX 60 support depends on future NVIDIA CUDA architecture/toolkit support.

---

## 🔴 AMD OpenCL Support

The AMD build uses **OpenCL**.

It is intended for AMD GPUs with working OpenCL runtime support through AMD drivers.

### AMD Requirements

- AMD GPU
- Latest AMD Adrenalin drivers recommended on Windows
- AMD OpenCL runtime installed
- 4GB+ VRAM recommended

AMD cards do not require CUDA-style architecture flags like `sm_120`.  
OpenCL support is handled through the AMD driver/runtime.

---

## 📋 Requirements

| Requirement | NVIDIA Build | AMD Build |
|---|---|---|
| GPU | NVIDIA GPU | AMD GPU |
| Backend | CUDA | OpenCL |
| VRAM | 4GB+ recommended | 4GB+ recommended |
| OS | Windows / Linux | Windows / Linux |
| Drivers | Latest NVIDIA drivers recommended | Latest AMD drivers recommended |

---

## 📖 Documentation

Full mining guide including setup, solo mining, pool mining, and troubleshooting:

**[📖 The Book of OGG — GitBook](https://oggcoin.gitbook.io/the-book-of-ogg)**

---

## ⚡ Quick Start

OggMiner is a command-line program.

Launch it from a Windows Command Prompt / PowerShell or Linux terminal, or use the included start scripts.

Full list of available commands:

```sh
oggminer --help
````

---

## 🧱 Mining Modes

OggMiner supports two mining modes:

1. **Solo mining** — mine directly to your own Oggchain node.
2. **Pool mining** — mine through the official OGG mining pool.

---

## ⛏️ Solo Mining

Solo mining connects directly to your Oggchain node RPC.

### NVIDIA — Windows

```bat
oggminer.exe -U -P http://rpcuser:rpcpassword@127.0.0.1:18545
```

### NVIDIA — Linux

```bash
./oggminer -U -P http://rpcuser:rpcpassword@127.0.0.1:18545
```

### AMD — Windows

```bat
oggminer.exe -G -P http://rpcuser:rpcpassword@127.0.0.1:18545
```

### AMD — Linux

```bash
./oggminer -G -P http://rpcuser:rpcpassword@127.0.0.1:18545
```

| Flag | Description          |
| ---- | -------------------- |
| `-U` | Use NVIDIA CUDA      |
| `-G` | Use AMD OpenCL       |
| `-P` | RPC or pool endpoint |

---

## 🏊 Pool Mining

Pool mining connects to the official OGG mining pool.

### NVIDIA — Windows

```bat
oggminer.exe -U -P stratum1+tcp://YOUR_WALLET_ADDRESS@pool.oggcoin.org:PORT
```

### NVIDIA — Linux

```bash
./oggminer -U -P stratum1+tcp://YOUR_WALLET_ADDRESS@pool.oggcoin.org:PORT
```

### AMD — Windows

```bat
oggminer.exe -G -P stratum1+tcp://YOUR_WALLET_ADDRESS@pool.oggcoin.org:PORT
```

### AMD — Linux

```bash
./oggminer -G -P stratum1+tcp://YOUR_WALLET_ADDRESS@pool.oggcoin.org:PORT
```

Mining Pool:

**[https://pool.oggcoin.org](https://pool.oggcoin.org)**

Replace:

```text
YOUR_WALLET_ADDRESS
```

with your OGG wallet address.

---

## 📦 Included Scripts

Release packages include ready-to-edit start files.

### Windows

```text
solo_OGG.bat
pool_OGG.bat
```

### Linux

```text
solo_OGG.sh
pool_OGG.sh
```

Use the solo script to mine directly to your own node.
Use the pool script to mine through the official OGG mining pool.

---

## 🛠️ Build From Source

### Verified Build Environment

OggMiner has been configured and successfully built with the following tool versions. Different versions may work, but are not guaranteed.

| Tool                       | Version              |
| -------------------------- | -------------------- |
| Visual Studio              | 2022                 |
| CMake                      | 3.21+                |
| Perl                       | v5.42                |
| CUDA Toolkit               | 13.2                 |
| OpenCL Headers             | vcpkg OpenCL package |
| Hunter C++ Package Manager | 6.6.0                |

> Hunter 6.6.0 is used automatically by CMake to download and build C++ dependencies. You do not call it directly. It runs during the `cmake ..` configuration step.

---

## 🟢 Build NVIDIA CUDA Miner — Windows

```cmd
mkdir build-cuda
cd build-cuda
cmake .. -G "Visual Studio 17 2022" -A x64 -DETHASHCUDA=ON -DETHASHCL=OFF -DETHASHCPU=OFF -DAPICORE=ON
cmake --build . --config Release --parallel
```

---

## 🔴 Build AMD OpenCL Miner — Windows

Install OpenCL headers/libraries first. One working method is using `vcpkg`.

```cmd
cd C:\
git clone https://github.com/microsoft/vcpkg.git
cd C:\vcpkg
bootstrap-vcpkg.bat
vcpkg.exe install opencl:x64-windows
```

Then build OggMiner:

```cmd
cd C:\path\to\oggminer
mkdir build-amd
cd build-amd
cmake .. -G "Visual Studio 17 2022" -A x64 ^
-DETHASHCUDA=OFF ^
-DETHASHCL=ON ^
-DETHASHCPU=OFF ^
-DAPICORE=ON ^
-DCMAKE_TOOLCHAIN_FILE=C:\vcpkg\scripts\buildsystems\vcpkg.cmake ^
-DOpenCL_INCLUDE_DIR=C:\vcpkg\installed\x64-windows\include ^
-DOpenCL_LIBRARY=C:\vcpkg\installed\x64-windows\lib\OpenCL.lib

cmake --build . --config Release --parallel
```

---

## 🐧 Build NVIDIA CUDA Miner — Linux

```bash
mkdir build-cuda
cd build-cuda
cmake .. -DETHASHCUDA=ON -DETHASHCL=OFF -DETHASHCPU=OFF -DAPICORE=ON
make -j$(nproc)
```

---

## 🔴 Build AMD OpenCL Miner — Linux

```bash
mkdir build-amd
cd build-amd
cmake .. -DETHASHCUDA=OFF -DETHASHCL=ON -DETHASHCPU=OFF -DAPICORE=ON
make -j$(nproc)
```

---

## 🧪 Benchmarking

OggMiner supports benchmarking against specific epochs / DAGs / block numbers.

Run:

```sh
oggminer --help
```

to see all available benchmark options.

---

## 🧰 Troubleshooting

### Miner does not detect NVIDIA GPU

* Make sure you are using the NVIDIA CUDA build.
* Install latest NVIDIA drivers.
* Make sure the GPU has enough VRAM.
* Try running from Command Prompt / terminal to see full error output.

### Miner does not detect AMD GPU

* Make sure you are using the AMD/OpenCL build.
* Install latest AMD drivers.
* Confirm OpenCL runtime is installed.
* Try running from Command Prompt / terminal to see full error output.

### Pool mining does not start

Check:

* Wallet address is correct.
* Pool endpoint and port are correct.
* Internet/firewall allows the connection.
* You are using the correct backend flag:

  * `-U` for NVIDIA
  * `-G` for AMD

---

## 🤝 Contribute

Bug reports, pull requests, and code reviews are welcome.

---

## 🔗 Links

|                |                                                                                          |
| -------------- | ---------------------------------------------------------------------------------------- |
| 🌐 Website     | [https://oggcoin.org](https://oggcoin.org)                                               |
| 📖 Docs        | [https://oggcoin.gitbook.io/the-book-of-ogg](https://oggcoin.gitbook.io/the-book-of-ogg) |
| ⛏️ Mining Pool | [https://pool.oggcoin.org](https://pool.oggcoin.org)                                     |
| 💬 Telegram    | [https://t.me/proveyouogg](https://t.me/proveyouogg)                                     |
| 🐦 Twitter/X   | [https://x.com/oggchain](https://x.com/oggchain)                                         |
| 🎮 Discord     | [https://discord.gg/VrBQz7upZb](https://discord.gg/VrBQz7upZb)                           |
| 💻 GitHub      | [https://github.com/Oggcoin](https://github.com/Oggcoin)                                 |

---

## 📄 License

Licensed under the [GNU General Public License, Version 3](LICENSE).

Forked from [progminer](https://github.com/hydnoracoin/progminer) — originally forked from [ethminer](https://github.com/ethereum-mining/ethminer).

---

🪨 **OggMiner. GPU powered. Cave connected. Mine early. Mine hard.**

```
```

