import { ethers, getNamedAccounts } from "hardhat"
import { P2pEth2Depositor__factory } from "../typechain-types"

const fakeGwei = {
    pubkey: '0xa8ecef195708fe44c63ce9a3a141b6bd314951877f5c42d0e77cab38bff25ba1539d20eeb8cdbb5fa702b085adaa941e',
    withdrawal_credentials: '0x00a6c79b5077fa73f8a0448fcdf8aeefd19d690ee97189f97010446f79aeaf82',
    signature: '0x9411e7873d5a95c0784b01124846f587e98cb500af48c3a98f6e5d067f0a0fde5a9e148545883369da23c0dfae07d161130f66228932248574dbc2e4689caa037ab86f98f1fa4802a43894b3db48c55352ef3844df3fb445940f3333fa431ce8',
    deposit_data_root: '0xa01f384cb625353a835c3d721ef7b33363be3b23ca6e62a1a2d9248a2d4b68bc',
}

const depositData = [
    {"pubkey": "0xa8123deea37a396ee9d47230f64b6a39e7ffdc26320ba13e0fe68fba890ff7319da151d55d80a4e04ee6ee9773bf63d2",
        "withdrawal_credentials": "0x00b37ee37d23c359b6254e151c6e4372ce3a845ca3ab0965ec4f3a25558fe202",
        "amount": 32000000000,
        "signature": "0xac5dfc1da9807d5fe4d12908ffb937bbdf7cf8f8c1ec8777ab6b6be789d19dd3452339e8ac7d97ae332b8f70f2140c2c003b20c6093fa73f7211414d75b07235e08d02ef8da77203b99431ba4b875943246f19edf7e9301f0eaf07fb80f45e20",
        "deposit_message_root": "0x245047eea966cd41aac435a8ada1777d0e0cffb298b399fbf96b649081319578",
        "deposit_data_root": "0xaebcfe50b4f2b35744f8f4539722d04f6bfcece7ae3d1680c8ff2bc836436f34",
        "fork_version": "00001020", "network_name": "prater", "deposit_cli_version": "2.2.0"
    }, {"pubkey": "a84199f19794186d4bf21208359b7b166dfa72e326e893f4df762b33c670f699ebc66721dddb1f43c5514c28427d8c83", "withdrawal_credentials": "00135d7d016f9a1fdc0637b3a1fb729eb6e76b237c17ad7d3abaf55a9db5343f", "amount": 32000000000, "signature": "b7efd34397b4520dbab94713256c5d6110d2f59f37ae5e262450edb02630090ab42b88e66413bf8ba1e98b47626b5b0918447b4648a8cdc501e7a17523c93781b31d5a7d488193a9349dcffa672ba11fcd8ad117093bf17a202da07931f70708", "deposit_message_root": "5a4368a2f3a009b7840635daf7821e65daa6653d0cc971e82f1b6a00ce8a32f4", "deposit_data_root": "d40a0216d3f0b62e268559c2bd388342de1f99f4f41001ba183b83bf05354c41", "fork_version": "00001020", "network_name": "prater", "deposit_cli_version": "2.2.0"}, {"pubkey": "8075267c1e716c2723232b678c481369a4c708593998fdefbcec849f59a83ab30a17196e86ac4286dd34da91e64378c5", "withdrawal_credentials": "0065c982f3d479c2af4e2be99752eee9d3dd660717fa27d2e24537e831b3f845", "amount": 32000000000, "signature": "af0f9c92f18a9ac112dc7eaea92f5659f321eca553aa6fa55b7538b2737d72750a6adfb0cd056112688975eb4c3fb6cd0ad3243bb77e9ce6fb0a32cc940d429010472ae5b2fa300ac823266dd3887b3513c8f55f1321a9a42c4b93a8a904395b", "deposit_message_root": "267adb522f3d40cd68a761383a63544cd9f55d26ccd412b18c0088c5a8d4c702", "deposit_data_root": "59fbfb5babeb9bba186d611a31867ec6075ccdad29a963a90c912d4cea9af2c6", "fork_version": "00001020", "network_name": "prater", "deposit_cli_version": "2.2.0"}, {"pubkey": "b95524cf0a3adda6f8295533cd971122aced172371ece8d2da0d7604802a1b61c01f5404dd71ec470f56131939aba6c7", "withdrawal_credentials": "00b7f55f70e3c0056c4a54a53d0f373dd8eaaf3a39c5efb68554332007cb2c19", "amount": 32000000000, "signature": "870f0a180b39ff3273500c02d1ad8c0cdfbe7c6c06faf8e4aa5a02a1c47cfbfc8ad5c5b8ff76d1c32c2dd1f5cf67cec6124e61e7452cc2defd3e7ed499f07a09cb846131d42302df1f4269562c71a4cbd7dda9d0ff785d39938d3d64d91c9354", "deposit_message_root": "00215ad5bbaf0c00afa1854173e034001e7f769f7cd9a266358f1983359e39bc", "deposit_data_root": "32c72a2c1e57cd3a3f9eb0b419b93a8f04300caa969155a4b629724fd8ef393d", "fork_version": "00001020", "network_name": "prater", "deposit_cli_version": "2.2.0"}, {"pubkey": "a6737324a61843870b08d3e87850a72e2e76e2ccda2b688fa6122dafcb9b52ec4b0013d525286a0a6366bdc6ebfefd34", "withdrawal_credentials": "00a266f75fca45792f2c3abd0efbcd32da3d92802526a3ed7857eb95e55f9c49", "amount": 32000000000, "signature": "b4020a07e49c63a7f8eb3541a32cff1f571f0e0331813de19901e184c0c018438f07e40880c3d7d70e0410c353a0082009a303031edce3ae3be7cb0088d2470548ec8c351a0a4d2a9664efd07c2b0ee7ae06b2b7e40706e3423e5683aa3b8136", "deposit_message_root": "5cb0ba7a3b4d66ffd664acce365b0df489d71ce22566e4c1a6fc8add07b78609", "deposit_data_root": "0e7d8a3ec61e60765708d2e7119d20bae6a139e5ccafe1834c3c7a873ae1729a", "fork_version": "00001020", "network_name": "prater", "deposit_cli_version": "2.2.0"}, {"pubkey": "85e75384be0dd7a09d20643d4f3b423fb433a9c00824bc4d252cefabf60e2ab00a47d80ccd3ade34239e6442b54e2860", "withdrawal_credentials": "00b93ffe1b26fc07157ff5140804c1cd36d918b07ec0fd206d53eb094618dd29", "amount": 32000000000, "signature": "9069cd6419961fa6f8ab36f0b7f44cbb33bea2520f2854ffc7daad3cea0c3c92743b47c09bad754d8fa0a7d137737dc818f0e305b37b318723acf31aa9ff1f97195ea75851c462c5eb86b84961468d3d1e1736067b58c287bb7fdb0171c2c03b", "deposit_message_root": "0d859cdd2a008954a072c5b7cd4244152352b849aec9476122f042c38b77742f", "deposit_data_root": "38ddf0ae085cf874cb90f029134f7a82e87578c00e45552d7f63e3f29c086835", "fork_version": "00001020", "network_name": "prater", "deposit_cli_version": "2.2.0"}, {"pubkey": "8df68e473a5aa05c84701f59492dbc0207141afcc2d984543eb704f0cc01681b6f1340d8c744ef613401c01dc5610569", "withdrawal_credentials": "0086849854a9eacb22e3bc09aea938b5ee6717d9df1286884ff789a2a713ce60", "amount": 32000000000, "signature": "b793eb160140fbe817cd4c04f073b1820bed10e8a927839ee4a2793083c8b58ae1fb453a70172ad083a2489fcdbabd610de05a9ae0838204168a3d208eeb09137cbf0716c99fcef05f0902209d185aa94edfcd07491ade71dcb1755da37356bd", "deposit_message_root": "dabc41666ac117c81b22fcd559911363bf79df4ff72c4a2886f41e978f96f6e5", "deposit_data_root": "8b2807ba1b2ba404f3610d749c7ecf0d97d86dcbbae00bb633fe722a78c60d96", "fork_version": "00001020", "network_name": "prater", "deposit_cli_version": "2.2.0"}, {"pubkey": "aa01618fd2b75a9bfcc9ebe4695d5568339367305652413e828a807036122d6ec837f882ed9d6af50a70879ab26ded01", "withdrawal_credentials": "00e41211f0177e0c83eb945036a83979aa43d53c905d2ea2f1bec7eca0b9e9b7", "amount": 32000000000, "signature": "8f9c05f325e79fe1aa9822eb0657e221e61aee29dea10c14b65e1c41c2d9367bfca97f37dc9b3133e842bfd2e5ebf65814a5807739acfc42ea3a828c92f54f721e4774498c669b9b4d8f7f0fab45079eebeb9af6a04bcbd3347212ed9c1ed89d", "deposit_message_root": "c9d5502c30716b65fb29a8ff4a4e1410f2aef334b0778137b3fab0ae7aa57fee", "deposit_data_root": "64a1a58fe0e195b7bd5d851de39a59fbbbafa42d76f2166a3f32100afcff1df9", "fork_version": "00001020", "network_name": "prater", "deposit_cli_version": "2.2.0"}, {"pubkey": "984816d45d5d91478d53ada4dc325745a241d50002ed412c3f6a0d61e4321ef6b172075efb91937cc99b3f45e122ebaa", "withdrawal_credentials": "00e6eb44d7a1c167018e78395532aa1f900fe771a9537c9e468b217be8fc79dd", "amount": 32000000000, "signature": "a7aa55f870aabaad9157fcc7e85dd37fd02c484233deffe669931b50e3de1943d52e4d6fc8bb4d6fc62849606719568d02bbb0805c210398471c1f0c98c526865d5dd188a579bac2bb3c0c9c9dbffd672be5179c30d65ee9da690e88a5566b0d", "deposit_message_root": "45f0e97f1821934981bda59d8796863f618848eb6e0f3dcdec9db5cd505e9b57", "deposit_data_root": "6b6e07bbc19430a7b638722dd60f3ec29da43851b83088da90eaecfa5d477047", "fork_version": "00001020", "network_name": "prater", "deposit_cli_version": "2.2.0"}, {"pubkey": "a4763d6249e08033c30a075aff399922dd9378da6c3feb3df61ca588c806714304908cda20dcaf44264a1de0e97bf51c", "withdrawal_credentials": "00439171600630ba6eebe29790717a6fb66ead7df00cf555a6dc8345b9d1c1e2", "amount": 32000000000, "signature": "b5b587876d8d4884fedadefbff45ebced9c618ffd512c00aa5220edc3e5a7e85a928c05949058503cda2f30e883ee5e80532af235a0dbe9472ad09dc863aaac65da37e851e5b00abdd13aedf704baf9f00fa7a88ec7dd5854a5e20798ab07e4c", "deposit_message_root": "05437bed24cbb659f6a9cede72c503a890c51d3498a365c901c476abab63b486", "deposit_data_root": "ddb6572b244ce1c9c0bf308a71a3ec2344f40da4166ebff4e9020b3adb37c15d", "fork_version": "00001020", "network_name": "prater", "deposit_cli_version": "2.2.0"}]

// 0xa0c2283e0a575b440d02834f951ab6a77145c0f6dcc95d104d9cc32cd44959b3e82a6c980e35af902d0f8478426a0a81b16902d20d5d3ee3f8b64c2d9dbc363c843b9db2b94c47ebca61887d3e0b67b4d79a1b31773551b4216ca8ea938d8534

const clientBasisPoints = 9000;
const referrerBasisPoints = 400;
const clientAddress = '0x388C818CA8B9251b393131C08a736A67ccB19297'
const referrerAddress = '0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5'

async function main() {
    try {
        const { deployer } = await getNamedAccounts()
        const signer = await ethers.getSigner(deployer)

        // deploy factory contract
        const factoryFactory = new P2pEth2Depositor__factory(signer)
        let nonce = await ethers.provider.getTransactionCount(deployer)
        const testt = await factoryFactory.attach('0x4b917046c44d8c7d2490d562e1e3550063dab654')

        const tx = await testt.deposit(
            [...Array(314).keys()].map(index => depositData[0].pubkey),
            depositData[0].withdrawal_credentials,
            [...Array(314).keys()].map(index => depositData[0].signature),
            [...Array(314).keys()].map(index => depositData[0].deposit_data_root),
            { recipient: clientAddress, basisPoints: clientBasisPoints },
            { recipient: referrerAddress, basisPoints: referrerBasisPoints },
            {gasLimit: 15000000, value: ethers.utils.parseUnits('10048', 9)}
        )
        const txReceipt = await tx.wait(1)
        console.log(txReceipt.cumulativeGasUsed.toString())
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
