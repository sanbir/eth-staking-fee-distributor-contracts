// SPDX-FileCopyrightText: 2023 P2P Validator <info@p2p.org>
// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../../@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../../structs/P2pStructs.sol";
import "../../constants/P2pConstants.sol";
import "../../lib/NftRenderer.sol";
import "./BaseNftFeeDistributor.sol";
import "./INftFeeDistributor.sol";

/// @notice Need to pass only 1 (own) pubkey
error NftFeeDistributor__OnlyOnePubkeyPassed();

/// @notice Need to pass own pubkey
error NftFeeDistributor__WrongPubkeyPassed();

/// @title FeeDistributor accepting and splitting both CL and EL rewards.
/// @dev Its address must be used as 0x01 withdrawal credentials when making ETH2 deposit
contract NftFeeDistributor is BaseNftFeeDistributor, INftFeeDistributor {

    uint32 private s_validatorIndex;
    State private s_state;
    bytes private s_pubkey;

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
    /// @param uint32 for compatibility
    function increaseDepositedCount(uint32) external override {
        i_factory.check_Operator_Owner_P2pEth2Depositor(msg.sender);

        s_state = State.PostDeposit;

        emit NftFeeDistributor__Deposited();
    }

    /// @inheritdoc IFeeDistributor
    function voluntaryExit(bytes[] calldata _pubkeys) public override { // onlyClient due to BaseFeeDistributor
        if (_pubkeys.length != 1) {
            revert NftFeeDistributor__OnlyOnePubkeyPassed();
        }
        if (s_pubkey != _pubkeys[0]) {
            revert NftFeeDistributor__WrongPubkeyPassed();
        }

        s_state = State.ExitRequested;

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

    /// @notice Operator updates the start state of the validator
    /// Updates validator state to Active
    /// State.PostDeposit -> State.Active
    function validatorStarted(uint32 _validatorIndex, bytes calldata _pubkey) external {
        i_factory.checkOperatorOrOwner(msg.sender);

        s_validatorIndex = _validatorIndex;
        s_state = State.Active;
    }

    /// @notice Operator updates the exited from beaconchain.
    /// State.ExitRequested -> State.Exited
    function validatorExited() external;

    function validatorIndex() external view returns (uint256);

    function pubkey() external view returns (bytes memory);

    function state() external view returns (State) {
        return s_state;
    }

    function render() external view returns (string memory) {
        return NftRenderer.render(NftRenderer.RenderParams({
            tokenId: 42,
            nftArtURL: "data:image/png;base64,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",
            nftManager: address(i_nftManager),
            validatorIndex: 100500,
            validatorPubkey: bytes(0),
            state: s_state
        }));
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
