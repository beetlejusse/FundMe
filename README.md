# FUNDME

A funding-based smart contract written in **Solidity** using **Foundry**  
*Currently available on Ethereum testnets*

---

## 🚀 Overview

**FUNDME** is a decentralized smart contract that allows users to create funding campaigns and receive Ether from contributors. Built using the **Foundry** framework, the project aims to make development, testing, and deployment fast and simple.

---

## Features

- ✅ Developed in Solidity
- ✅ Built and tested using Foundry
- ✅ Pre-configured Makefile for automation
- ✅ Easily deployable to testnets like Sepolia

---

##  Prerequisites

Before running the project, ensure the following tools are installed:

- [Foundry](https://book.getfoundry.sh/foundry/getting-started/installation)
- [Make](https://www.gnu.org/software/make/) (For running Makefile commands)
- Ethereum-compatible wallet (e.g., MetaMask)
- RPC URL and private key for deployment (Check `.env` file handling in your setup)

---

## 🛠️ How to Build and Deploy

The project uses a `Makefile` for simplified automation. Follow the steps below:

### Step 1 – Build the Contract
```
make build
```
### Step 2 – Deploy to Sepolia Testnet
```
make deploy-sepolia
```

This will compile and  verify and deploy your smart contract.

> Make sure your environment variables (like RPC URL, private key and etherscan api key) are properly set before deploying. Use a `.env` file or export them in your shell.

---


<div align="center">
  Made with ❣️
</div>
