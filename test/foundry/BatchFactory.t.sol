// SPDX-FileCopyrightText: 2023 P2P Validator <info@p2p.org>
// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "forge-std/console2.sol";
import "../../contracts/BatchFactory.sol";
import "../../contracts/structs/P2pStructs.sol";

contract BatchFactoryTest is Test {

    BatchFactory batchFactory;

    function setUp() public {
        vm.createSelectFork("mainnet", 17857803);

        batchFactory = BatchFactory(0x8730D0be30c75f8cAb2805916D52C9F408E85e7a);
    }

    function test_deploy_fee_ditributors() public {
        uint256[] memory clientOnlyClRewardsArray = new uint256[](2);
        clientOnlyClRewardsArray[0] = 0;
        clientOnlyClRewardsArray[1] = 0;

        FeeRecipient[] memory clientConfigs = new FeeRecipient[](2);
        clientConfigs[0] = FeeRecipient({
            recipient: payable(0xB29B49E654A551D0DD9911F81F4C90470632205F),
            basisPoints: 9300
        });
        clientConfigs[1] = FeeRecipient({
        recipient: payable(0x3FE3827a6f36fd8047D3aAB3F0d69B0188950A31),
        basisPoints: 9300
        });

        vm.startPrank(0x588ede4403DF0082C5ab245b35F0f79EB2d8033a);
        batchFactory.createFeeDistributor(clientOnlyClRewardsArray, clientConfigs);
    }
}
