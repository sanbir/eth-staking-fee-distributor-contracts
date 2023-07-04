import { ethers, getNamedAccounts } from "hardhat"
import {
    ContractWcFeeDistributor__factory, ElOnlyFeeDistributor__factory,
    FeeDistributorFactory__factory,
    Oracle__factory, OracleFeeDistributor__factory, P2pOrgUnlimitedEthDepositor__factory
} from "../typechain-types"

const depositData = {
    "pubkey":"96e3676c2f7816cd91e29c563d5e9deb2197285fdf6eb5840034d35775b78cc492cdd8aa944d4d0bad0bab02fb128069",
    "withdrawal_credentials":"010000000000000000000000000000005504f0f5cf39b1ed609b892d23028e57",
    "amount":32000000000,
    "signature":"9666f85fffebe4b642d59729e0152ac9b704d115dd267bf123c31f3dcc78f68576a60d3e8a1a820b61a98a1341f1be1f0c9b04debd3eaf6a113aba24de72a4b2dca8e5cfe48a61707357cbb6a643aaf537d2657ac4fc101d9c36373e9d2ef673",
    "deposit_message_root":"5e0477fd54f5b9f0597911b354216ae0a2f511d783028c5c77c6d07ae7e9b1ca",
    "deposit_data_root":"aae7e345c5f3b8d1cee954f18ba304827df1d79b60fea8f846f1a2b2dda5fca9",
    "fork_version":"00001020","eth2_network_name":"goerli","deposit_cli_version":"2.3.0"}

const elOnlyFeeDistributorAddress = '0xcDf6F2d3F17d4d0036794d4F14aE3A54eb94AF32'

async function main() {
    try {
        const { deployer } = await getNamedAccounts()
        const deployerSigner = await ethers.getSigner(deployer)
        let nonce = await ethers.provider.getTransactionCount(deployer)
        const {name: chainName, chainId} = await ethers.provider.getNetwork()
        console.log('Started on: ' + chainName)

        const feeDistributorFactorySignedByDeployer = await new FeeDistributorFactory__factory(deployerSigner).attach('0x37FcbE7D16328036fd36A512b8D97cFd16779944')
        const oracleSignedByDeployer = await new Oracle__factory(deployerSigner).attach('0xe3c1E6958da770fBb492f8b6B85ea00ABb81E8f9')
        const ContractWcFeeDistributor = await new ContractWcFeeDistributor__factory(deployerSigner).attach('0x1f72FC2585D283DfEcF748cc5d19c014158A7C6f')
        const ElOnlyFeeDistributor = await new ElOnlyFeeDistributor__factory(deployerSigner).attach('0x8986df2E9b0D445d535a5b802d2d7306187747F9')
        const OracleFeeDistributor = await new OracleFeeDistributor__factory(deployerSigner).attach('0x18aB1EC5F2163FcdD6119723A0c61014e5e25e17')
        const p2pEth2DepositorSignedByDeployer = await new P2pOrgUnlimitedEthDepositor__factory(deployerSigner).attach('0x1cE72344682Cf649Bbbd87D4d45fe448021938e6')

        // await p2pEth2DepositorSignedByDeployer.addEth(
        //     ElOnlyFeeDistributor.address,
        //     { recipient: deployer, basisPoints: 9500 },
        //     { recipient: ethers.constants.AddressZero, basisPoints: 0 },
        //     {
        //         value: ethers.utils.parseUnits((32).toString(), 'ether'),
        //         maxFeePerGas: 50000000000,
        //         maxPriorityFeePerGas: 1000000000
        //     }
        // )

        // p2pEth2DepositorSignedByDeployer.makeBeaconDeposit(
        //     elOnlyFeeDistributorAddress,
        //     [depositData.pubkey],
        //     [depositData.signature],
        //     [depositData.deposit_data_root],
        //         {
        //             maxFeePerGas: 50000000000,
        //             maxPriorityFeePerGas: 1000000000
        //         }
        // )
        //
        // feeDistributorFactorySignedByDeployer.createFeeDistributor(
        //     ElOnlyFeeDistributor.address,
        //     { recipient: deployer, basisPoints: 9400 },
        //     { recipient: ethers.constants.AddressZero, basisPoints: 0 },
        //     {
        //         maxFeePerGas: 50000000000,
        //         maxPriorityFeePerGas: 1000000000
        //     }
        // )
        //
        // feeDistributorFactorySignedByDeployer.createFeeDistributor(
        //     OracleFeeDistributor.address,
        //     { recipient: deployer, basisPoints: 9500 },
        //     { recipient: ethers.constants.AddressZero, basisPoints: 0 },
        //     {
        //         maxFeePerGas: 50000000000,
        //         maxPriorityFeePerGas: 1000000000
        //     }
        // )
        //
        // await oracleSignedByDeployer.report('0x8ffa3563dd3de06e70d7dae30a456ec5737fa982193862a05e1eaf4fef6beb63');
        //
        // feeDistributorFactorySignedByDeployer.createFeeDistributor(
        //     ContractWcFeeDistributor.address,
        //     { recipient: deployer, basisPoints: 9500 },
        //     { recipient: ethers.constants.AddressZero, basisPoints: 0 },
        //     {
        //         maxFeePerGas: 50000000000,
        //         maxPriorityFeePerGas: 1000000000
        //     }
        // )

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

// Root: 0x8ffa3563dd3de06e70d7dae30a456ec5737fa982193862a05e1eaf4fef6beb63
// Proof:
// [
//     '0x482c22dca1afb1a7d8bf4c86db6a875ab302ad9e7ebc3baca15ca60207c3c5e0',
//     '0xa2d2d9599717e5e4d3e14d43cfd1d2cdf6befc8d91af26a12c7bad79e308050f'
// ]

