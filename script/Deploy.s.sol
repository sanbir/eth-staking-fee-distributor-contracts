// SPDX-FileCopyrightText: 2024 P2P Validator <info@p2p.org>
// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import "../contracts/P2pMessageSender.sol";
import "../contracts/feeDistributor/DeoracleizedFeeDistributor.sol";
import "../contracts/feeDistributorFactory/FeeDistributorFactory.sol";
import "../contracts/p2pEth2Depositor/P2pOrgUnlimitedEthDepositor.sol";
import {Script} from "forge-std/Script.sol";

contract Deploy is Script {
    address payable constant serviceAddress = payable(0x6Bb8b45a1C6eA816B70d76f83f7dC4f0f87365Ff);

    function run() external returns (P2pMessageSender, FeeDistributorFactory, P2pOrgUnlimitedEthDepositor, DeoracleizedFeeDistributor) {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);

        P2pMessageSender p2pMessageSender = new P2pMessageSender();

        FeeDistributorFactory feeDistributorFactory = new FeeDistributorFactory(9000);

        P2pOrgUnlimitedEthDepositor p2pOrgUnlimitedEthDepositor = new P2pOrgUnlimitedEthDepositor(address(feeDistributorFactory));

        DeoracleizedFeeDistributor deoracleizedFeeDistributorTemplate = new DeoracleizedFeeDistributor(
            address(feeDistributorFactory),
            serviceAddress
        );

        feeDistributorFactory.changeOperator(0xdff3F5DBd6B6c929460dC48251F328035bb87D93);

        vm.stopBroadcast();

        return (p2pMessageSender, feeDistributorFactory, p2pOrgUnlimitedEthDepositor, deoracleizedFeeDistributorTemplate);
    }
}

