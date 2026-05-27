# 🪨 OggMiner
> Custom GPU miner for Oggchain. Built on OggPoW — a custom Go implementation of ProgPoW.

**OggMiner** is a GPU mining worker built specifically for the Oggchain network. It is forked from [progminer](https://github.com/hydnoracoin/progminer) and adjusted to work with **OggPoW** — Oggchain's custom ProgPoW implementation written in Go.

With OggMiner you can mine OGG on Oggchain via solo mining direct to your node or via the official OGG mining pool.

Forked from [progminer](https://github.com/hydnoracoin/progminer) which originates from [ethminer](https://github.com/ethereum-mining/ethminer). Check the original [ProgPoW](https://github.com/ifdefelse/progpow) implementation and [EIP-1057](https://eips.ethereum.org/EIPS/eip-1057) for specification.

---

## ⛏️ Features

- GPU mining for Oggchain (OggPoW — custom ProgPoW implementation)
- NVIDIA CUDA mining — latest CUDA supported
- OpenCL mining (AMD)
- Solo mining direct to Oggchain node via RPC
- Pool mining via official OGG pool
- On-GPU DAG generation
- Realistic benchmarking against arbitrary epoch/DAG/blocknumber
- Windows and Linux support
- ASIC resistant — GPU focused from block one

---

## 📋 Requirements

| Requirement | Detail |
|---|---|
| GPU | NVIDIA or AMD |
| VRAM | 4 GB minimum |
| OS | Windows 10/11 or Linux (Ubuntu 20.04+) |
| NVIDIA | Latest CUDA drivers |
| AMD | AMD Adrenalin Software |

---

## 📖 Documentation

Full mining guide including setup, solo mining, pool mining, and troubleshooting:

**[📖 The Book of OGG — GitBook](https://oggcoin.gitbook.io/the-book-of-ogg)**

---

## ⚡ Quick Start

OggMiner is a command line program. Launch it from a Windows command prompt or Linux terminal, or create a start script.

Full list of available commands:

```sh
oggminer --help
```

### Solo Mining — Connect direct to your Oggchain node

**NVIDIA — Windows:**
```bat
oggminer.exe -U -P http://rpcuser:rpcpassword@127.0.0.1:18545
```

**NVIDIA — Linux:**
```bash
./oggminer -U -P http://rpcuser:rpcpassword@127.0.0.1:18545
```

**AMD — Windows:**
```bat
oggminer.exe -G -P http://rpcuser:rpcpassword@127.0.0.1:18545
```

**AMD — Linux:**
```bash
./oggminer -G -P http://rpcuser:rpcpassword@127.0.0.1:18545
```

| Flag | Description |
|---|---|
| `-U` | Use NVIDIA CUDA |
| `-G` | Use AMD OpenCL |
| `-P` | RPC or pool endpoint |

### Pool Mining — Connect to official OGG pool

**NVIDIA:**
```bash
./oggminer -U -P stratum1+tcp://YOUR_WALLET_ADDRESS@pool.oggcoin.org:PORT
```

**AMD:**
```bash
./oggminer -G -P stratum1+tcp://YOUR_WALLET_ADDRESS@pool.oggcoin.org:PORT
```

**Mining Pool:** [https://pool.oggcoin.org](https://pool.oggcoin.org)

---


### Verified Build Environment

OggMiner has been configured and successfully built with the following tool versions. Using different versions may work but is not guaranteed.

| Tool | Version |
|---|---|
| Visual Studio | 2022 |
| CMake | 3.21 |
| Perl | v5.42 |
| CUDA Toolkit | 13.2 |
| Hunter (C++ pkg manager) | 6.6.0 |

> **Note:** Hunter is used automatically by CMake to download and build C++ dependencies. You do not call it directly — it runs during the `cmake ..` configuration step. The first configure will take several minutes while Hunter fetches and builds all dependencies.


### Windows

```cmd
mkdir build
cd build
cmake .. -G "Visual Studio 17 2022" -A x64 -DETHASHCUDA=ON -DETHASHCL=OFF -DAPICORE=ON
cmake --build . --config Release --parallel
```

### Linux

```bash
mkdir build
cd build
cmake .. -DETHASHCUDA=ON -DETHASHCL=ON -DAPICORE=ON
make -j$(nproc)
```

---

## 🤝 Contribute

All bug reports, pull requests and code reviews are welcome.

---

## 🔗 Links

| | |
|---|---|
| 🌐 Website | https://oggcoin.org |
| 📖 Docs | https://oggcoin.gitbook.io/the-book-of-ogg |
| ⛏️ Mining Pool | https://pool.oggcoin.org |
| 💬 Telegram | https://t.me/proveyouogg |
| 🐦 Twitter/X | https://x.com/oggchain |
| 🎮 Discord | https://discord.gg/VrBQz7upZb |
| 💻 GitHub | https://github.com/Oggcoin |

---

## 📄 License

Licensed under the [GNU General Public License, Version 3](LICENSE).

Forked from [progminer](https://github.com/hydnoracoin/progminer) — originally forked from [ethminer](https://github.com/ethereum-mining/ethminer).

---

🪨 **OggMiner. GPU powered. Cave connected. Mine early. Mine hard.**
