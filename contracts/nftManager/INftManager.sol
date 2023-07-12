// SPDX-FileCopyrightText: 2023 P2P Validator <info@p2p.org>
// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface INftManager is IERC165 {

    /// @notice lookups the NFT Owner by address => tokenId => owner
    /// @param validator address created by mint
    /// @return address of the owner
    function validatorOwner(address validator) external view returns (address);
}
