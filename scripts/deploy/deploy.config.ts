import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Networks } from '../../hardhat.config'

/**
 * Get the deploy config for a given network
 * @param network
 * @returns
 */
export const getDeployConfig = (network: DeployableNetworks, signers?: SignerWithAddress[]): DeploymentVariables => {
  const config = deployableNetworkConfig[network]
  if (!config) {
    throw new Error(`No deploy config for network ${network}`)
  }
  return config(signers)
}

/**
 * Extract networks as deployments are needed
 *
 * NOTE: Add networks as needed
 */
export type DeployableNetworks = Extract<Networks, 'bsc' | 'bscTestnet' | 'mainnet' | 'goerli' | 'sepolia' | 'polygon' | 'polygonTestnet' >

/**
 * Deployment Variables for each network
 *
 * NOTE: Update variables as needed
 */
interface DeploymentVariables {
  proxyAdminAddress: string
  adminAddress: string | SignerWithAddress
  wNative: string
}

const deployableNetworkConfig: Record<DeployableNetworks, (signers?: SignerWithAddress[]) => DeploymentVariables> = {
  bsc: (signers?: SignerWithAddress[]) => {
    return {
      proxyAdminAddress: '0x',
      // NOTE: Example of extracting signers
      adminAddress: signers?.[0] || '0x',
      wNative: '0x',
    }
  },
  mainnet: (signers?: SignerWithAddress[]) => {
    return {
      proxyAdminAddress: '0x',
      // NOTE: Example of extracting signers
      adminAddress: signers?.[0] || '0x',
      wNative: '0x',
    }
  },
  polygon: (signers?: SignerWithAddress[]) => {
    return {
      proxyAdminAddress: '0x',
      // NOTE: Example of extracting signers
      adminAddress: signers?.[0] || '0x',
      wNative: '0x',
    }
  },
  bscTestnet: (signers?: SignerWithAddress[]) => {
    return {
      proxyAdminAddress: '0x',
      adminAddress: signers?.[0] || '0x',
      wNative: '0x',
    }
  },
  goerli: (signers?: SignerWithAddress[]) => {
    return {
      proxyAdminAddress: '0x',
      adminAddress: signers?.[0] || '0x',
      wNative: '0x',
    }
  },
  sepolia: (signers?: SignerWithAddress[]) => {
    return {
      proxyAdminAddress: '0x',
      adminAddress: signers?.[0] || '0x',
      wNative: '0x',
    }
  },
  polygonTestnet: (signers?: SignerWithAddress[]) => {
    return {
      proxyAdminAddress: '0x',
      adminAddress: signers?.[0] || '0x',
      wNative: '0x',
    }
  },
}
