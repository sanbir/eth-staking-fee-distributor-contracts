import { ethers, getNamedAccounts } from "hardhat"
import {
    BatchFactory__factory,
    ContractWcFeeDistributor__factory, ElOnlyFeeDistributor__factory,
    FeeDistributorFactory__factory,
    Oracle__factory, OracleFeeDistributor__factory, P2pOrgUnlimitedEthDepositor__factory
} from "../typechain-types"

async function main() {
    try {
        const { deployer } = await getNamedAccounts()
        const deployerSigner = await ethers.getSigner(deployer)
        const {name: chainName, chainId} = await ethers.provider.getNetwork()
        console.log('Deploying to: ' + chainName)

        const feeDistributorFactorySignedByDeployer = await new BatchFactory__factory(deployerSigner).deploy(
            '0x86a9f3e908b4658A1327952Eb1eC297a4212E1bb',
            '0x7109DeEb07aa9Eed1e2613F88b2f3E1e6C05163f',
            {gasLimit: 1200000, maxPriorityFeePerGas: 100000000, maxFeePerGas: 16000000000}
        )
        await feeDistributorFactorySignedByDeployer.deployed()
        console.log('FeeDistributorFactory deployed at: ' +  feeDistributorFactorySignedByDeployer.address)

        console.log('Done.')
    } catch (err) {
        console.log(err)
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});


// Deploying to: goerli
// FeeDistributorFactory deployed at: 0x8C87EFBA90414687A66C8B2E7D21039E81d55456
// Oracle deployed at: 0x6aA04FA882E4Cd26F0354B07Ee1884Fe156f78B2
// ContractWcFeeDistributor instance deployed at: 0x46320E8a9F101D43e7502dbFc06aaCE389448986
// ElOnlyFeeDistributor instance deployed at: 0x94EDf7e950fA01bAa44a8690cAC64264cdB7cA7c
// OracleFeeDistributor instance deployed at: 0xAD91441aB557b5eC5d9f29DB64522Eb918B4f32b
// P2pEth2Depositor deployed at: 0x38129624175aC89337B5068B8364EfC5F539a567
//

