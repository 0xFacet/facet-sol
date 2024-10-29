// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibRLP } from "lib/solady/src/utils/LibRLP.sol";

library LibFacet {
    using LibRLP for LibRLP.List;

    address constant facetInboxAddress = 0x00000000000000000000000000000000000FacE7;
    bytes32 constant facetEventSignature = 0x00000000000000000000000000000000000000000000000000000000000face7;
    uint8 constant facetTxType = 0x46;

    function sendFacetTransaction(
        uint256 gasLimit,
        bytes memory data
    ) internal {
        sendFacetTransaction({
            to: bytes(''),
            value: 0,
            maxFeePerGas: 10_000 gwei,
            gasLimit: gasLimit,
            data: data
        });
    }

    function sendFacetTransaction(
        address to,
        uint256 gasLimit,
        bytes memory data
    ) internal {
        sendFacetTransaction({
            to: abi.encodePacked(to),
            value: 0,
            maxFeePerGas: 10_000 gwei,
            gasLimit: gasLimit,
            data: data
        });
    }

    function prepareFacetTransaction(
        bytes memory to,
        uint256 value,
        uint256 maxFeePerGas,
        uint256 gasLimit,
        bytes memory data
    ) internal view returns (bytes memory) {
        uint256 chainId;

        if (block.chainid == 1) {
            chainId = 0xface7;
        } else if (block.chainid == 11155111) {
            chainId = 0xface7a;
        } else {
            revert("Unsupported chainId");
        }

        LibRLP.List memory list;

        list.p(chainId);
        list.p(to);
        list.p(value);
        list.p(maxFeePerGas);
        list.p(gasLimit);
        list.p(data);

        return abi.encodePacked(facetTxType, list.encode());
    }

    function sendFacetTransaction(
        bytes memory to,
        uint256 value,
        uint256 maxFeePerGas,
        uint256 gasLimit,
        bytes memory data
    ) internal {
        bytes memory payload = prepareFacetTransaction(to, value, maxFeePerGas, gasLimit, data);

        assembly {
            log1(add(payload, 32), mload(payload), facetEventSignature)
        }
    }
}
