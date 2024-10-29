// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { LibFacet } from "src/utils/LibFacet.sol";

abstract contract FoundryFacetSender {
    function sendFacetTransactionFoundry(
        bytes memory to,
        uint256 value,
        uint256 maxFeePerGas,
        uint256 gasLimit,
        bytes memory data
    ) internal {
        bytes memory payload = LibFacet.prepareFacetTransaction({
            to: to,
            value: value,
            maxFeePerGas: maxFeePerGas,
            gasLimit: gasLimit,
            data: data
        });

        (bool success, ) = LibFacet.facetInboxAddress.call(payload);
        require(success, "Facet transaction failed");
    }

    function sendFacetTransactionFoundry(
        uint256 gasLimit,
        bytes memory data
    ) internal {
        sendFacetTransactionFoundry({
            to: bytes(''),
            gasLimit: gasLimit,
            value: 0,
            maxFeePerGas: 10_000 gwei,
            data: data
        });
    }

    function sendFacetTransactionFoundry(
        address to,
        uint256 gasLimit,
        bytes memory data
    ) internal {
        sendFacetTransactionFoundry({
            to: abi.encodePacked(to),
            gasLimit: gasLimit,
            value: 0,
            maxFeePerGas: 10_000 gwei,
            data: data
        });
    }
}
