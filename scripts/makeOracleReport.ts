import { Oracle__factory } from "../typechain-types"
import { ethers, getNamedAccounts } from "hardhat"
import { logger } from "./logger"

export async function makeOracleReport(
    oracleAddress: string,
    root: string,
    settings: {
        gasLimit: number,
        nonce: number
    }
) {
    logger.info('makeOracleReport started')

    const { deployer } = await getNamedAccounts()
    const deployerSigner = await ethers.getSigner(deployer)

    const oracle = Oracle__factory.connect(
        oracleAddress,
        deployerSigner
    )

    const tx = await oracle.report(root, settings)
    await tx.wait(1)
    settings.nonce += 1

    logger.info('makeOracleReport finished')
}
