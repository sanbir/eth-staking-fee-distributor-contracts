// SPDX-FileCopyrightText: 2023 P2P Validator <info@p2p.org>
// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../../@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../../@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "../../@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "../../feeDistributorFactory/IFeeDistributorFactory.sol";
import "../../assetRecovering/OwnableTokenRecoverer.sol";
import "../../access/OwnableWithOperator.sol";
import "../IFeeDistributor.sol";
import "../FeeDistributorErrors.sol";
import "../../structs/P2pStructs.sol";
import "../../lib/P2pAddressLib.sol";
import "../Erc4337Account.sol";
import "../../nftManager/INftManager.sol";

/// @notice Should be an NftManager contract
/// @param _passedAddress passed address that does not support INftManager interface
error NftFeeDistributor__NotNftManager(address _passedAddress);

/// @title Common logic for NftFeeDistributor
abstract contract BaseNftFeeDistributor is Erc4337Account, OwnableTokenRecoverer, OwnableWithOperator, ReentrancyGuard, ERC165, IFeeDistributor {

    /// @notice NftManager address
    INftManager internal immutable i_nftManager;

    /// @notice FeeDistributorFactory address
    IFeeDistributorFactory internal immutable i_factory;

    /// @notice P2P fee recipient address
    address payable internal immutable i_service;

    /// @notice client basis points
    uint96 s_clientBasisPoints;

    /// @notice If caller not client, revert
    modifier onlyClient() {
        address clientAddress = client();

        if (clientAddress != msg.sender) {
            revert FeeDistributor__CallerNotClient(msg.sender, clientAddress);
        }
        _;
    }

    /// @notice If caller not factory, revert
    modifier onlyFactory() {
        if (msg.sender != address(i_factory)) {
            revert FeeDistributor__NotFactoryCalled(msg.sender, i_factory);
        }
        _;
    }

    /// @dev Set values that are constant, common for all the clients, known at the initial deploy time.
    /// @param _nftManager address of NftManager
    /// @param _factory address of FeeDistributorFactory
    /// @param _service address of the service (P2P) fee recipient
    constructor(
        address _nftManager,
        address _factory,
        address payable _service
    ) {
        if (!ERC165Checker.supportsInterface(_nftManager, type(INftManager).interfaceId)) {
            revert NftFeeDistributor__NotNftManager(_nftManager);
        }
        if (!ERC165Checker.supportsInterface(_factory, type(IFeeDistributorFactory).interfaceId)) {
            revert FeeDistributor__NotFactory(_factory);
        }
        if (_service == address(0)) {
            revert FeeDistributor__ZeroAddressService();
        }

        i_nftManager = INftManager(_nftManager);
        i_factory = IFeeDistributorFactory(_factory);
        i_service = _service;

        bool serviceCanReceiveEther = P2pAddressLib._sendValue(_service, 0);
        if (!serviceCanReceiveEther) {
            revert FeeDistributor__ServiceCannotReceiveEther(_service);
        }
    }

    /// @inheritdoc IFeeDistributor
    function initialize(
        FeeRecipient calldata _clientConfig,
        FeeRecipient calldata
    ) external onlyFactory {
        if (_clientConfig.basisPoints > 10000) {
            revert FeeDistributor__InvalidClientBasisPoints(_clientConfig.basisPoints);
        }

        s_clientBasisPoints = _clientConfig.basisPoints;

        emit FeeDistributor__Initialized(
            address(0),
            _clientConfig.basisPoints,
            address(0),
            0
        );
    }

    /// @notice Accept ether from transactions
    receive() external payable {
        // only accept ether in an instance, not in a template
        if (client() == address(0)) {
            revert FeeDistributor__ClientNotSet();
        }
    }

    /// @inheritdoc IFeeDistributor
    function increaseDepositedCount(uint32 _validatorCountToAdd) external virtual;

    /// @inheritdoc IFeeDistributor
    function voluntaryExit(bytes[] calldata _pubkeys) public virtual onlyClient {
        emit FeeDistributor__VoluntaryExit(_pubkeys);
    }

    /// @inheritdoc IFeeDistributor
    function factory() external view returns (address) {
        return address(i_factory);
    }

    /// @inheritdoc IFeeDistributor
    function service() external view returns (address) {
        return i_service;
    }

    /// @inheritdoc IFeeDistributor
    function client() public view override(Erc4337Account, IFeeDistributor) returns (address) {
        return i_nftManager.validatorOwner(address(this));
    }

    /// @inheritdoc IFeeDistributor
    function clientBasisPoints() external view returns (uint256) {
        return s_clientBasisPoints;
    }

    /// @inheritdoc IFeeDistributor
    function referrer() external pure returns (address) {
        return address(0);
    }

    /// @inheritdoc IFeeDistributor
    function referrerBasisPoints() external pure returns (uint256) {
        return 0;
    }

    /// @inheritdoc IFeeDistributor
    function eth2WithdrawalCredentialsAddress() external virtual view returns (address);

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IFeeDistributor).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IOwnable
    /// @dev do not confuse with the NFT owner
    function owner() public view override(Erc4337Account, OwnableBase, Ownable) returns (address) {
        return i_factory.owner();
    }

    /// @inheritdoc IOwnableWithOperator
    function operator() public view override(Erc4337Account, OwnableWithOperator) returns (address) {
        return super.operator();
    }
}
