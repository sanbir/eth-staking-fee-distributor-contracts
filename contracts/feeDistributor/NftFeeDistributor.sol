// SPDX-FileCopyrightText: 2023 P2P Validator <info@p2p.org>
// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../structs/P2pStructs.sol";
import "../constants/P2pConstants.sol";
import "./BaseNftFeeDistributor.sol";

/// @notice Need to pass at least 1 pubkey that needs to be exited
error NftFeeDistributor__NoPubkeysPassed();

/// @notice The number of pubkeys exceeds the number of non-exited validators
error NftFeeDistributor__TooManyPubkeysPassed();

/// @title FeeDistributor accepting and splitting both CL and EL rewards.
/// @dev Its address must be used as 0x01 withdrawal credentials when making ETH2 deposit
contract NftFeeDistributor is BaseNftFeeDistributor {

    /// @notice Emits when new ETH2 deposits have been reported
    /// @param _added number of newly added validators
    /// @param _newDepositedCount total number of all client deposited validators after the add
    event NftFeeDistributor__DepositedCountIncreased(
        uint32 _added,
        uint32 _newDepositedCount
    );

    /// @notice Emits when new validators have been requested to exit
    /// @param _added number of newly requested to exit validators
    /// @param _newExitedCount total number of all client validators ever requested to exit
    event NftFeeDistributor__ExitedCountIncreased(
        uint32 _added,
        uint32 _newExitedCount
    );

    /// @notice Emits when new collaterals (multiples of 32 ETH) have been returned to the client
    /// @param _added number of newly returned collaterals
    /// @param _newCollateralReturnedCount total number of all collaterals returned to the client
    event NftFeeDistributor__CollateralReturnedCountIncreased(
        uint32 _added,
        uint32 _newCollateralReturnedCount
    );

    /// @dev depositedCount, exitedCount, collateralReturnedCount stored in 1 storage slot
    ValidatorData private s_validatorData;

    /// @dev Set values that are constant, common for all the clients, known at the initial deploy time.
    /// @param _nftManager address of NftManager
    /// @param _factory address of FeeDistributorFactory
    /// @param _service address of the service (P2P) fee recipient
    constructor(
        address _nftManager,
        address _factory,
        address payable _service
    ) BaseNftFeeDistributor(_nftManager, _factory, _service) {
    }

    /// @notice Report that new ETH2 deposits have been made
    /// @param _validatorCountToAdd number of newly deposited validators
    function increaseDepositedCount(uint32 _validatorCountToAdd) external override {
        i_factory.check_Operator_Owner_P2pEth2Depositor(msg.sender);

        s_validatorData.depositedCount += _validatorCountToAdd;

        emit NftFeeDistributor__DepositedCountIncreased(
            _validatorCountToAdd,
            s_validatorData.depositedCount
        );
    }

    /// @inheritdoc IFeeDistributor
    function voluntaryExit(bytes[] calldata _pubkeys) public override { // onlyClient due to BaseFeeDistributor
        if (_pubkeys.length == 0) {
            revert NftFeeDistributor__NoPubkeysPassed();
        }
        if (_pubkeys.length > s_validatorData.depositedCount - s_validatorData.exitedCount) {
            revert NftFeeDistributor__TooManyPubkeysPassed();
        }

        s_validatorData.exitedCount += uint32(_pubkeys.length);

        emit NftFeeDistributor__ExitedCountIncreased(
            uint32(_pubkeys.length),
            s_validatorData.exitedCount
        );

        super.voluntaryExit(_pubkeys);
    }

    /// @notice Withdraw the whole balance of the contract according to the pre-defined basis points.
    /// @dev In case someone (either service, or client, or referrer) fails to accept ether,
    /// the owner will be able to recover some of their share.
    /// This scenario is very unlikely. It can only happen if that someone is a contract
    /// whose receive function changed its behavior since FeeDistributor's initialization.
    /// It can never happen unless the receiving party themselves wants it to happen.
    /// We strongly recommend against intentional reverts in the receive function
    /// because the remaining parties might call `withdraw` again multiple times without waiting
    /// for the owner to recover ether for the reverting party.
    /// In fact, as a punishment for the reverting party, before the recovering,
    /// 1 more regular `withdraw` will happen, rewarding the non-reverting parties again.
    /// `recoverEther` function is just an emergency backup plan and does not replace `withdraw`.
    function withdraw() external nonReentrant {
        address payable client = payable(client());
        if (client == address(0)) {
            revert FeeDistributor__ClientNotSet();
        }

        // get the contract's balance
        uint256 balance = address(this).balance;

        if (balance == 0) {
            // revert if there is no ether to withdraw
            revert FeeDistributor__NothingToWithdraw();
        }

        if (balance >= COLLATERAL && s_validatorData.collateralReturnedCount < s_validatorData.exitedCount) {
            // if exited and some validators withdrawn

            // integer division
            uint32 collateralsCountToReturn = uint32(balance / COLLATERAL);

            s_validatorData.collateralReturnedCount += collateralsCountToReturn;

            emit NftFeeDistributor__CollateralReturnedCountIncreased(
                collateralsCountToReturn,
                s_validatorData.collateralReturnedCount
            );

            // Send collaterals to client
            P2pAddressLib._sendValue(
                client,
                collateralsCountToReturn * COLLATERAL
            );

            // Balance remainder to split
            balance = address(this).balance;
        }

        // how much should client get
        uint256 clientAmount = (balance * s_clientBasisPoints) / 10000;

        // how much should service get
        uint256 serviceAmount = balance - clientAmount;

        // Send ETH to service. Ignore the possible yet unlikely revert in the receive function.
        P2pAddressLib._sendValue(
            i_service,
            serviceAmount
        );

        // Send ETH to client. Ignore the possible yet unlikely revert in the receive function.
        P2pAddressLib._sendValue(
            client,
            clientAmount
        );

        emit FeeDistributor__Withdrawn(
            serviceAmount,
            clientAmount,
            0
        );
    }

    /// @notice Recover ether in a rare case when either service, or client, or referrer
    /// refuse to accept ether.
    /// @param _to receiver address
    function recoverEther(address payable _to) external onlyOwner {
        this.withdraw();

        // get the contract's balance
        uint256 balance = address(this).balance;

        if (balance > 0) { // only happens if at least 1 party reverted in their receive
            bool success = P2pAddressLib._sendValue(_to, balance);

            if (success) {
                emit FeeDistributor__EtherRecovered(_to, balance);
            } else {
                emit FeeDistributor__EtherRecoveryFailed(_to, balance);
            }
        }
    }

    /// @notice Returns the number of validators reported as deposited
    /// @return uint32 number of validators
    function depositedCount() external view returns (uint32) {
        return s_validatorData.depositedCount;
    }

    /// @notice Returns the number of validators requested to exit
    /// @return uint32 number of validators
    function exitedCount() external view returns (uint32) {
        return s_validatorData.exitedCount;
    }

    /// @notice Returns the number of collaterals (multiples of 32 ETH) returned to the client
    /// @return uint32 number of collaterals
    function collateralReturnedCount() external view returns (uint32) {
        return s_validatorData.collateralReturnedCount;
    }

    /// @inheritdoc IFeeDistributor
    /// @dev FeeDistributor's own address
    function eth2WithdrawalCredentialsAddress() external override view returns (address) {
        return address(this);
    }
}
