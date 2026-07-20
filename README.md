# NetCal — React + Express + C

A networking utilities web app with three tools:

- **IP Group Allocator** — allocate IP ranges across groups within a CIDR block
- **Subnet Calculator** — compute network/broadcast address, usable hosts, mask, class, private/public
- **TCP/UDP Header Analyzer** — decode raw packet headers from a hex string

## Stack

| Layer    | Tech                        |
|----------|-----------------------------|
| Frontend | React + Vite + React Router |
| Backend  | Express (Node.js)           |
| Logic    | JS ports of `server/*.c`    |

## Running

### Prerequisites
- Node.js 18+

### 1. Install all dependencies
```bash
npm run install:all
```

### 2. Start both server and client
```bash
npm run dev
```

- Express API → http://localhost:3001  
- React app → http://localhost:5173

## API Endpoints

| Method | Path          | Body                              |
|--------|---------------|-----------------------------------|
| POST   | /api/allocate | `{ cidr, groups: [{persons, ipsPerPerson}] }` |
| POST   | /api/subnet   | `{ cidr }`                        |
| POST   | /api/header   | `{ header }` (hex string)         |

## Running Server Tests
```bash
npm --prefix server test
```
