# 🌐 NetCalc — Flutter + WebAssembly Network Toolkit

**NetCalc** is a modern browser-based networking toolkit built with **Flutter Web** and **C + WebAssembly (WASM)**.  
It lets you analyze, calculate, and simulate various network operations right from your browser — fast, lightweight, and offline-capable.

---

## 🚀 Features

### 🧩 Core Modules
| Module | Description |
|---------|--------------|
| **IP Analyzer** | Parses and classifies IP addresses and subnet masks (`xxx.xxx.xxx.xxx/xx`). Displays class, usable hosts, broadcast & network addresses. |
| **Transport Header Analyzer** | Decodes raw TCP and UDP transport headers from hexadecimal input and shows protocol details (ports, checksum, flags, etc.). |
| **IP Group Allocator** | Allocates IP address ranges for multiple groups and persons based on starting CIDR. Generates detailed allocation tables and exports them as Excel. |

---

## 🛠️ Built With

| Technology | Purpose |
|-------------|----------|
| 🦋 **Flutter Web** | Beautiful, reactive UI and cross-platform web build |
| 🧬 **Emscripten (C → WASM)** | Converts C logic into WebAssembly for high-speed network computation |
| 💡 **Dart JS Interop** | Seamless communication between Dart (Flutter) and compiled WASM modules |
| 📘 **Excel Package** | Exports allocation results as `.xlsx` files directly in the browser |
| ⚙️ **GitHub Pages** | Serves the full Flutter web app directly from GitHub |

---

## 🧮 Modules Overview

### 🔹 IP Analyzer
- Input: `xxx.xxx.xxx.xxx/xx`
- Output:  
  - IP class (A/B/C/D/E)  
  - Network address  
  - Broadcast address  
  - Total and usable hosts  
  - Validation for malformed IPs  

### 🔹 TCP/UDP Header Decoder
- Input: Hexadecimal string (e.g., `0A0B0016001F1A2B00000001...`)
- Output:
  - Source & Destination ports
  - Header Length
  - Sequence & Acknowledgment numbers
  - Protocol identification (TCP/UDP)
  - Flags, Window, Checksum, Urgent pointer

### 🔹 IP Group Allocator
- Input: JSON + CIDR  
  Example:
  ```json
  {
    "Groups": 3,
    "Group": [0, 1, 2],
    "Person": [100, 50, 30],
    "ip": [256, 128, 64]
  }

