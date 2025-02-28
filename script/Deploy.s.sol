// SPDX-FileCopyrightText: 2024 P2P Validator <info@p2p.org>
// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "../contracts/BatchCallDelegation.sol";
import "../contracts/P2pMessageSender.sol";
import "../contracts/feeDistributor/DeoracleizedFeeDistributor.sol";
import "../contracts/feeDistributorFactory/FeeDistributorFactory.sol";
import "../contracts/p2pEth2Depositor/P2pOrgUnlimitedEthDepositor.sol";
import "../contracts/structs/P2pStructs.sol";
import {Script} from "forge-std/Script.sol";

contract Deploy is Script {
    address payable constant serviceAddress =
        payable(0x6Bb8b45a1C6eA816B70d76f83f7dC4f0f87365Ff);

    IDepositContract public constant depositContract = IDepositContract(0x4242424242424242424242424242424242424242);

    function run() external returns (DeoracleizedFeeDistributor) {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);

//        P2pMessageSender p2pMessageSender = new P2pMessageSender();
//
//        FeeDistributorFactory feeDistributorFactory = new FeeDistributorFactory(9000);
//
//        P2pOrgUnlimitedEthDepositor p2pOrgUnlimitedEthDepositor = new P2pOrgUnlimitedEthDepositor(address(feeDistributorFactory));

        DeoracleizedFeeDistributor deoracleizedFeeDistributorTemplate = new DeoracleizedFeeDistributor(
            0x0458b649B640C53A124060D2CBb81C428d17f42e,
            serviceAddress
        );

        // feeDistributorFactory.changeOperator(0x8814212123A73C37E2B43aaF9Cd3b2D58C80F650);

        vm.stopBroadcast();

        return (deoracleizedFeeDistributorTemplate);
    }

//    function run() external {
//        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
//
//        vm.startBroadcast(deployerKey);
//
////        P2pOrgUnlimitedEthDepositor p2pOrgUnlimitedEthDepositor = P2pOrgUnlimitedEthDepositor(
////            payable(0xd88eA323b51513cdD4bD581c872903dC8c7Ef8fe));
////
////        p2pOrgUnlimitedEthDepositor.addEth{
////                value: 32 ether
////            }(
////            0x010000000000000000000000aa00bA0D63B6Ed05130c5A80805c25Bcd0cA62d9,
////            uint96(32 ether),
////            0x6c882B6bffe33e9D1abBE0afAa6b070F4308EB66,
////            FeeRecipient({
////                recipient: payable(0xaa00bA0D63B6Ed05130c5A80805c25Bcd0cA62d9),
////                basisPoints: 9000
////            }),
////            FeeRecipient({
////                recipient: payable(address(0)),
////                basisPoints: 0
////            }),
////            ""
////        );
//
//        BatchCallDelegation batchCallDelegation = new BatchCallDelegation();
//
////        depositContract.deposit{value: 32 ether}(
////        hex'9361bd183010c8a60e76045960f4de9b530f2882d38ce8f4817ee7389c93badb0ffde6474e762f7a9cc049f18f44f38d',
////        hex'020000000000000000000000000000005504f0f5cf39b1ed609b892d23028e57',
////        hex'834e60fd04a9b7cf4d8ea46ac92a5b2503f887425b86bf119d5a4c6e50e03c57cb3ab0a0d8d8c95ba9c73df1db1e6ecf16b1229c70a2c7478612948ec506d4d6d45f735743156d5a77dafd0da99f258e60e5ddc2843344cec19bb8b9081e0b48',
////        0x4ab879aff089c6ad42b317d54a0513d96eb10684cf30c0c064d31d5f968df58c
////        );
//
//        vm.stopBroadcast();
//    }
}
