# Agora
This repository contains the smart contracts for the Agora protocol. All the code can be found inside the [contracts](/contracts) folder and the repo uses the Hardhat toolset.

## Build
In order to build the contracts, run the `yarn run build` command, or `npm run build` if you're using npm. This runs the `hardhat compile` function under the hood and creates an `articats` folder that contains the bytecode and ABI for the contracts.

## Security
Two audits from independent security researchers have been completed on the codebase before it was deployed on the Avalanche networks. The (small) issues that were identified were fixed before the deolpoyment happened. The audit reports can be found inside the [audits](/audits) folder. We also encourage all developers to examine the code and submit any vulnerabilities to security@stakewithagora.com (bug bounties available).
