// SPDX-FileCopyrightText: 2023 P2P Validator <info@p2p.org>
// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./access/Ownable.sol";
import "./access/OwnableWithOperator.sol";
import "./feeDistributorFactory/FeeDistributorFactory.sol";
import "./feeDistributor/IFeeDistributor.sol";

contract BatchFactory is OwnableWithOperator {

    FeeDistributorFactory immutable i_factory;

    constructor(address factory) {
        i_factory = FeeDistributorFactory(factory);
    }

    function createFeeDistributor(
        IFeeDistributor.FeeRecipient[] calldata _clientConfigs,
        IFeeDistributor.ValidatorData[] calldata _validatorDatas
    ) external {
        require(owner() == msg.sender || operator() == msg.sender, 'BatchFactory: Not authorized');

        uint256 count = _clientConfigs.length;

        for (uint256 i = 0; i < count;) {
            i_factory.createFeeDistributor(
                _clientConfigs[i],
                IFeeDistributor.FeeRecipient({basisPoints: 0, recipient: payable(address(0))}),
                _validatorDatas[i]
            );

            unchecked {
                ++i;
            }
        }
    }
}
