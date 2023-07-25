import { ethers, getNamedAccounts } from "hardhat"
import {
    BatchFactory__factory
} from "../typechain-types"

async function main() {
    try {
        const { deployer } = await getNamedAccounts()
        const deployerSigner = await ethers.getSigner(deployer)
        let nonce = await ethers.provider.getTransactionCount(deployer)
        const {name: chainName} = await ethers.provider.getNetwork()
        console.log('Deploying to: ' + chainName)

        const BatchFactory = await new BatchFactory__factory(deployerSigner).deploy(
            '0xE9DfC1850110DadF68402Ec6AD2B9bDfB7980733', {
                gasLimit: 1000000,
                maxPriorityFeePerGas: 60000000000,
                maxFeePerGas: 600000000000,
                nonce
            }
        )
        await BatchFactory.deployed()
        console.log('BatchFactory deployed at: ' +  BatchFactory.address)

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
// BatchFactory deployed at: 0xF54349C0fAA8Df52121e2637822E04f72687Ca4F
//



