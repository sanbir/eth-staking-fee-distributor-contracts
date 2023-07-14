// SPDX-FileCopyrightText: 2023 P2P Validator <info@p2p.org>
// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "Base64.sol";
import "Strings.sol";
import "IStakefishValidator.sol";
import "Utils.sol";
import "../feeDistributor/nft/INftFeeDistributor.sol";

library NftRenderer {
    struct RenderParams {
        uint256 tokenId;
        string nftArtURL;
        address nftManager;
        uint256 validatorIndex;
        bytes validatorPubkey;
        INftFeeDistributor.State state;
    }

    function render(RenderParams memory params) public pure returns (string memory) {
        string memory description = renderDescription(params);
        string memory name = string.concat(" validator #", Strings.toString(params.tokenId));
        string memory json = string.concat(
            '{"name":"', name,'",',
            '"description":"',description,'",',
            '"image": "', params.nftArtURL, Strings.toString(params.tokenId),
            '"}'
        );

        return string.concat(
            "data:application/json;base64,",
            Base64.encode(bytes(json))
        );
    }

    function renderDescription(RenderParams memory params) internal pure returns (string memory description) {
        description = string.concat(
            "This NFT represents a P2P Ethereum validator minted with 32 ETH. ",
            "Owner of this NFT controls the withdrawal credentials, receives protocol rewards, and receives fee/mev rewards.\\n",
            "\\n\\nNFT Manager: ", Strings.toHexString(uint256(uint160(params.nftManager)), 20),
            "\\nValidator Index: ", Strings.toString(params.validatorIndex),
            "\\n\\nDISCLAIMER: Due diligence is important when evaluating this NFT. Make sure issuer/nft manager match the official nft manager on P2P.org, as token symbols may be imitated."
        );
    }
}
