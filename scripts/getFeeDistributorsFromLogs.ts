import { IFeeDistributorFactory__factory } from "../typechain-types"
import { ethers } from "hardhat"
import { logger } from "./logger"

export async function getFeeDistributorsFromLogs(feeDistributorFactoryAddress: string) {

    logger.info('getFeeDistributorsFromLogs started')

    const factory = IFeeDistributorFactory__factory.connect(
        feeDistributorFactoryAddress,
        ethers.provider
    )

    const filter = factory.filters.FeeDistributorCreated(null, null)

    let result = await factory.queryFilter(filter, 0, "latest");

    const feeDistributors = result.map(event => event.args._newFeeDistributorAddress)

    logger.info('getFeeDistributorsFromLogs finished')

    return feeDistributors
}
