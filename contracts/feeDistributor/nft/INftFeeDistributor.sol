// SPDX-FileCopyrightText: 2023 P2P Validator <info@p2p.org>
// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

contract INftFeeDistributor {
    event NftFeeDistributor__Deposited();
    event NftFeeDistributor__Started(bytes _validatorPubKey);
    event NftFeeDistributor__Exited(bytes _validatorPubKey);
    event NftFeeDistributor__Withdrawn(bytes _validatorPubKey, uint256 _amount);

    enum State {
        PreDeposit,
        PostDeposit,
        Active,
        ExitRequested,
        Exited,
        Withdrawn,
        Burnable
    }

    function validatorIndex() external view returns (uint256);

    function pubkey() external view returns (bytes memory);

    function state() external view returns (State);

    /// @notice Operator updates the start state of the validator
    /// Updates validator state to Active
    /// State.PostDeposit -> State.Active
    function validatorStarted(uint32 _validatorIndex) external;

    /// @notice Operator updates the exited from beaconchain.
    /// State.ExitRequested -> State.Exited
    function validatorExited() external;

    function render() external view returns (string memory);
}
