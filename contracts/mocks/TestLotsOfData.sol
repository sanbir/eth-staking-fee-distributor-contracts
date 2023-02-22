// SPDX-FileCopyrightText: 2022 P2P Validator <info@p2p.org>
// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/**
* @title This is a mock for testing only.
* @dev DO NOT deploy in production!
*/
contract TestLotsOfData {
    /**
    * @dev 256bits-wide structure to store CL data provided by an oracle.
    */
    struct OracleReport {
        /**
        * @notice validator's balance on Beacon chain in Wei
        */
        uint128 clBalance;

        /**
        * @notice total withdrawals from Beacon chain in Wei
        */
        uint128 clWithdrawals;
    }

    // Validator Public Key hash => OracleReport
    mapping(bytes32 => OracleReport) s_oracleReports;

    function report(
        bytes32[] calldata pubKeys,
        OracleReport[] calldata oracleReports
    ) external {
        uint256 length = pubKeys.length;
        require(length == oracleReports.length);

        for (uint256 i = 0; i < length; ++i)
            s_oracleReports[pubKeys[i]] = oracleReports[i];
    }
}
