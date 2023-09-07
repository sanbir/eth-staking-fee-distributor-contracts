import { ethers, getNamedAccounts } from "hardhat"
import { FeeDistributor__factory } from "../typechain-types"
import { BigNumber } from "ethers"
import { logger } from "./logger"

export async function getLegacyClientOnlyClRewardsOne(address: string) {
    logger.info('getLegacyClientOnlyClRewardsOne started for ' + address)

    const { deployer } = await getNamedAccounts()
    const deployerSigner = await ethers.getSigner(deployer)

    const feeDistributor = FeeDistributor__factory.connect(
        address,
        deployerSigner
    )

    const legacyAlreadySplitClRewards = await feeDistributor.clientOnlyClRewards()

    logger.info('getLegacyClientOnlyClRewardsOne finished for ' + address)

    return (legacyAlreadySplitClRewards as BigNumber).div(1e9).toNumber()
}
