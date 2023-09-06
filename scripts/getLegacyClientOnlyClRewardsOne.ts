import { ethers, getNamedAccounts } from "hardhat"
import { FeeDistributor__factory } from "../typechain-types"
import { BigNumber } from "ethers"

export async function getLegacyClientOnlyClRewardsOne(address: string) {
    const { deployer } = await getNamedAccounts()
    const deployerSigner = await ethers.getSigner(deployer)

    const feeDistributor = FeeDistributor__factory.connect(
        address,
        deployerSigner
    )

    const legacyAlreadySplitClRewards = await feeDistributor.clientOnlyClRewards()

    return (legacyAlreadySplitClRewards as BigNumber).div(1e9).toNumber()
}
