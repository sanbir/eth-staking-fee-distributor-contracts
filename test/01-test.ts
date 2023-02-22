import { expect } from "chai"
import {ethers, getNamedAccounts} from "hardhat"
import {
    TestLotsOfData,
    TestLotsOfData__factory
} from "../typechain-types"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"

function getRandomInt(max: number) {
    return Math.floor(Math.random() * max);
}

function generateData(count: number): {
    oracleReports: { clBalance: number; clWithdrawals: number }[];
    pubKeys: string[]
} {
    const pubKeys = [...Array(count).keys()].map(index => (
        ethers.utils.hexZeroPad(ethers.utils.hexlify(index + 1), 32)
    ))

    const oracleReports = [...Array(count).keys()].map(index => (
        {clBalance: getRandomInt(count), clWithdrawals: getRandomInt(count)}
    ))

    return { pubKeys, oracleReports }
}

describe("TestLotsOfData", function () {

    let deployer: string

    let deployerSigner: SignerWithAddress

    let deployerTestLotsOfDataFactory: TestLotsOfData__factory

    before(async () => {
        const namedAccounts = await getNamedAccounts()
        deployer = namedAccounts.deployer
        deployerSigner = await ethers.getSigner(deployer)
        deployerTestLotsOfDataFactory = new TestLotsOfData__factory(deployerSigner)
    })


    it("test gas TestLotsOfData", async function () {
        const testLotsOfData = await deployerTestLotsOfDataFactory.deploy({gasLimit: 3000000})
        //
        const {oracleReports, pubKeys} = generateData(1000);
        //
        const tx = await testLotsOfData.report(pubKeys, oracleReports)
        const txReceipt = await tx.wait(1)
        console.log(txReceipt.cumulativeGasUsed.toString())
    })
})
