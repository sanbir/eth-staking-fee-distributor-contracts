// SPDX-FileCopyrightText: 2023 P2P Validator <info@p2p.org>
// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./access/Ownable.sol";
import "./access/OwnableWithOperator.sol";
import "./feeDistributorFactory/FeeDistributorFactory.sol";
import "./feeDistributor/OracleFeeDistributor.sol";
import "./structs/P2pStructs.sol";

contract BatchFactory is OwnableWithOperator {

    FeeDistributorFactory immutable i_factory;
    address immutable i_referenceFeeDistributor;

    constructor(address factory, address referenceFeeDistributor) {
        i_factory = FeeDistributorFactory(factory);
        i_referenceFeeDistributor = referenceFeeDistributor;
    }

    function createFeeDistributor(
        uint256[] calldata clientOnlyClRewardsArray,
        FeeRecipient[] calldata _clientConfigs
    ) external {
        require(owner() == msg.sender || operator() == msg.sender, 'BatchFactory: Not authorized');

        uint256 count = _clientConfigs.length;

        for (uint256 i = 0; i < count;) {
            OracleFeeDistributor newFeeDistributor = OracleFeeDistributor(payable(i_factory.createFeeDistributor(
                i_referenceFeeDistributor,
                _clientConfigs[i],
                FeeRecipient({basisPoints: 0, recipient: payable(address(0))})
            )));

            newFeeDistributor.setClientOnlyClRewards(clientOnlyClRewardsArray[i]);

            unchecked {
                ++i;
            }
        }
    }
}
