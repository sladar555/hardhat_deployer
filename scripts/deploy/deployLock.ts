import { ethers, network } from 'hardhat'
import { getDeployConfig, DeployableNetworks } from './deploy.config'
import { DeployManager } from './DeployManager'
import { getEnv } from '../../hardhat/utils'

/**
 * // NOTE: This is an example of the default hardhat deployment approach.
 * This project takes deployments one step further by assigning each deployment
 * its own task in ../tasks/ organized by date.
 */
async function main() {
  const currentNetwork = network.name as DeployableNetworks
  // Optionally pass in accounts to be able to use them in the deployConfig
  const accounts = await ethers.getSigners()
  const { wNative, adminAddress } = getDeployConfig(currentNetwork, accounts)
  // Optionally pass in signer to deploy contracts
  const deployManager = new DeployManager(accounts[0])

  const currentTimestampInSeconds = Math.round(Date.now() / 1000)
  const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60
  const unlockTime = currentTimestampInSeconds + ONE_YEAR_IN_SECS

  const lockedAmount = ethers.utils.parseEther('.00001')

  const lockContractName = getEnv('CONTRACT_NAME')
  const Lock = await ethers.getContractFactory(lockContractName)
  const lock = await deployManager.deployContractFromFactory(
    Lock,
    lockContractName // Pass in contract name to log contract
  )
  console.log('Deploying ... ', lock.address)

  await sleep(30000);

  await deployManager.verifyContracts()
}

const sleep = (milliseconds: any) => {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
};

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
