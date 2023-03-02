//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.7.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";

library HexStrings {
    bytes16 internal constant ALPHABET = "0123456789abcdef";

    function toHexString(
        uint256 value,
        uint256 length
    ) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = ALPHABET[value & 0xf];
            value >>= 4;
        }
        return string(buffer);
    }
}

contract YourCollectible is ERC721, Ownable {
    using Strings for uint256;
    using HexStrings for uint160;
    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;

    constructor() public ERC721("Pinocchio Loogies", "PILO") {}

    function mintItem() public payable returns (uint256) {
        require(
            msg.value >= 0.5 ether,
            "Minimum 0.5 Matic needs to be paid for minting!"
        );
        require(tokenIds.current() < 10, "NFT minting limit reached!");
        tokenIds.increment();
        uint256 _id = tokenIds.current();
        _mint(msg.sender, _id);
        payable(owner()).transfer(msg.value);
        return _id;
    }

    function tokenURI(
        uint256 _id
    ) public view override returns (string memory) {
        require(_exists(_id), "NFT with the following id doesn't exist!");
        string memory _name = string(
            abi.encodePacked("Pinocchio Loogie #", _id.toString())
        );
        string memory _description = string(
            abi.encodePacked(
                "This is one of the 10 special edition Pinocchio Loogies. Every Pinocchio Loogie has a different nose length!"
            )
        );
        string memory _image = Base64.encode(
            bytes(generateSVGofTokenById(_id))
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                _name,
                                '", "description":"',
                                _description,
                                '", "attributes": [{"trait_type": "Nose Length", "value": "',
                                (100 - ((_id - 1) * 10)).toString(),
                                '%"}], "owner":"',
                                (uint160(ownerOf(_id))).toHexString(20),
                                '", "image": "',
                                "data:image/svg+xml;base64,",
                                _image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function generateSVGofTokenById(
        uint256 _id
    ) internal pure returns (string memory) {
        string memory _svg = string(
            abi.encodePacked(
                '<svg width="350" height="350" xmlns="http://www.w3.org/2000/svg">',
                renderTokenById(_id),
                "</svg>"
            )
        );

        return _svg;
    }

    function renderTokenById(uint256 _id) public pure returns (string memory) {
        string memory _render = string(
            abi.encodePacked(
                '<g id="eye1">',
                '<ellipse cx="181.5" cy="154.5" rx="29.5" ry="29.5" fill="#FFFFFF" stroke="#000000" stroke-width="3"/>',
                '<ellipse cx="173.5" cy="154.5" rx="2.5" ry="3.5" fill="#000000" stroke="#000000" stroke-width="3"/>',
                "</g>",
                '<g id="head">',
                '<ellipse cx="204.5" cy="211.80065" rx="59" ry="51.80065" fill="#FFCC99" stroke="#000000" stroke-width="3"/>',
                "</g>",
                '<g id="eye2">',
                '<ellipse cx="209.5" cy="168.5" rx="29.5" ry="29.5" fill="#FFFFFF"  stroke="#000000" stroke-width="3"/>',
                '<ellipse cx="208" cy="169.5" rx="3" ry="3.5" fill="#000000" stroke="#000000" stroke-width="3"/>',
                "</g>",
                '<g id="nose">',
                '<polygon points="165,195 165,215 ',
                (_id * 10).toString(),
                ',205" fill="#FFCC99" stroke="#000000" stroke-width="3"/>',
                "</g>",
                '<g id="mouth" transform="translate(25,0)" >',
                '<path d="M 130 240 Q 165 250 200 235" fill="transparent" stroke="black" stroke-width="3"/>',
                "</g>"
            )
        );

        return _render;
    }

    function uint2str(
        uint _i
    ) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
