## Deployment and Verification

This project uses special tasks, adapted from Balancer protocol, to deploy and verify contracts which provides methods for saving custom outputs and easily verifying contracts as well as compartmentalizing different types of deployments.

### Configuration

- Copy [.env.example](./.env.example) and rename to `.env`
  - Provide the necessary `env` variables before deployment/verification
  - `_MNEMONIC`: private key for deployments
  - `CONTRACT_NAME` :smart contract name
- [./contracts/](./[CONTRACT_NAME].sol): Can be configured with CONTRACT_NAME

## Deployment & Verification

 Run a deployment and verification with `yarn deploy <network>`
  - yarn deploy mainnet
  - yarn deploy bsc
  - yarn deploy polygon

  For testnet

  - yarn deploy goerli
  - yarn deploy bscTestnet
  - yarn deploy polygonTestnet


  
