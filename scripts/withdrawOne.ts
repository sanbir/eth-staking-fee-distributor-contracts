import { FeeDistributor__factory } from "../typechain-types"
import { ethers, getNamedAccounts } from "hardhat"
import { logger } from "./logger"

export async function withdrawOne(
    feeDistributorAddress: string,
    proof: string[],
    amountInGwei: number,
    settings: {
        gasLimit: number,
        nonce: number
    }
) {
    logger.info('withdrawOne started for ' + feeDistributorAddress)

    const { deployer } = await getNamedAccounts()
    const deployerSigner = await ethers.getSigner(deployer)

    const feeDistributor = FeeDistributor__factory.connect(
        feeDistributorAddress,
        deployerSigner
    )

    const balance = await ethers.provider.getBalance(feeDistributor.address);
    if (balance.gt(0)) {
        logger.info(feeDistributor.address, 'will withdraw')

        const tx = await feeDistributor.withdraw(proof, amountInGwei, settings)
        await tx.wait(1)
        settings.nonce += 1

        logger.info(feeDistributor.address, 'withdrew')
    } else {
        logger.info(feeDistributor.address, '0 balance')
    }

    logger.info('withdrawOne finished for ' + feeDistributorAddress)
}
