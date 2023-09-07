import fs from "fs"
import { buildMerkleTreeForValidatorBatch } from "./buildMerkleTreeForValidatorBatch"
import { makeOracleReport } from "./makeOracleReport"
import { withdrawAll } from "./withdrawAll"
import { getIitialClientOnlyClRewards } from "./getIitialClientOnlyClRewards"
import { ethers, getNamedAccounts } from "hardhat"
import { getLegacyClientOnlyClRewards } from "./getLegacyClientOnlyClRewards"
import { logger } from "./logger"

async function main() {
    logger.info('Started')
    const fdsWithLegacyClientOnlyClRewards = await getLegacyClientOnlyClRewards()

    fs.writeFileSync("fdsWithLegacyClientOnlyClRewards.json", JSON.stringify(fdsWithLegacyClientOnlyClRewards))

    const { deployer } = await getNamedAccounts()
    const settings = {
        gasLimit: 200000,
        nonce: await ethers.provider.getTransactionCount(deployer)
    }

    const validatorDataArray = await getIitialClientOnlyClRewards()

    fs.writeFileSync("validatorDataArray.json", JSON.stringify(validatorDataArray))

    for (const item of validatorDataArray) {
        const fd = fdsWithLegacyClientOnlyClRewards.find(f => f.oracleId === item.oracleId)

        if (!fd) {
            throw new Error('fd not found')
        }

        item.sum += fd.legacyClientOnlyClRewards
    }

    const batchRewardData = validatorDataArray.map(d => ([
        d.oracleId,
        d.validatorCount,
        d.sum
    ]))

    fs.writeFileSync("batchRewardData.json", JSON.stringify(batchRewardData))

    const tree = buildMerkleTreeForValidatorBatch(batchRewardData)

    // Send tree.json file to the website and to the withdrawer
    fs.writeFileSync("tree.json", JSON.stringify(tree.dump()))

    logger.info('Finished')
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    logger.error(error)
    process.exitCode = 1;
});
