// SPDX-FileCopyrightText: 2023 P2P Validator <info@p2p.org>
// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./INftManager.sol";
import "../feeDistributor/nft/INftFeeDistributor.sol";
import "../p2pEth2Depositor/IP2pOrgUnlimitedEthDepositor.sol";

/// @title NftManager implementation
/// @notice Extends ERC721, mints and burns NFT representing validators
contract NftManager is INftManager, ERC721Enumerable, ReentrancyGuard {

    IP2pOrgUnlimitedEthDepositor public immutable override i_depositor;

    /// @dev deployed validator contract => tokenId
    mapping(address => uint256) private s_validatorToToken;

    /// @dev tokenId => deployed validator contract
    mapping(uint256 => address) private s_tokenToValidator;

    /// @dev The ID of the next token that will be minted.
    uint256 internal s_nextId = 1;

    constructor(address _depositor) ERC721("P2P Validator", "P2P") {
        require(_depositor != address(0), "missing depositor");
        i_depositor = _depositor;
    }

    function setReferenceFeeDistributor() {

    }

    function mint(uint256 _validatorCount) external override payable nonReentrant {
        require(_validatorCount != 0, "wrong value: at least 1 validator must be minted");
        require(msg.value == _validatorCount * 32 ether, "wrong value: must be 32 ETH per validator");
        for (uint256 i=0; i < _validatorCount; i++) {
            _mintOne();
        }
    }

    function withdraw(uint256 _tokenId) external override nonReentrant {
        require(ownerOf(_tokenId) == msg.sender, 'Not nft owner');

        address validatorAddr = validatorForTokenId(_tokenId);
        IValidator(validatorAddr).withdraw();
        burnIfNecessary(_tokenId);
    }

    function burnIfNecessary(uint256 _tokenId) internal {
        address validatorAddr = validatorForTokenId(_tokenId);

        if (validatorAddr == address(0)) {
            return;
        }

        IValidator.StateChange memory lastState = IValidator(validatorAddr).lastStateChange();
        if (lastState.state == IValidator.State.Burnable) {
            _burn(_tokenId);
            s_validatorToToken[validatorAddr] = 0;
            s_tokenToValidator[_tokenId] = address(0);

            emit BurnedWithContract(_tokenId, validatorAddr, msg.sender);
        }
    }

    function validatorOwner(address _validator) external override view returns (address) {
        return ownerOf(s_validatorToToken[_validator]);
    }

    function validatorForTokenId(uint256 _tokenId) public override view returns (address) {
        return s_tokenToValidator[_tokenId];
    }

    function tokenForValidatorAddr(address _validator) external override view returns (uint256) {
        return s_validatorToToken[_validator];
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, IERC721Metadata) returns (string memory)
    {
        INftFeeDistributor validator = INftFeeDistributor(validatorForTokenId(tokenId));
        return validator.render();
    }

    function _mintOne() internal {
        uint256 tokenId = s_nextId++;
        address validatorAddr = i_depositor.addEth{value: 32 ether}(tokenId);

        _mint(msg.sender, tokenId);

        require(s_validatorToToken[validatorAddr] == 0, "mint: must be empty tokenId");
        s_validatorToToken[validatorAddr] = tokenId;
        s_tokenToValidator[tokenId] = validatorAddr;

        emit MintedWithContract(tokenId, validatorAddr, msg.sender);
    }

}
