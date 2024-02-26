

pragma solidity 0.8.23;

import {EIP712} from "solady/utils/EIP712.sol";
import { Ownable } from "solady/auth/Ownable.sol";
import {SignatureCheckerLib} from "solady/utils/SignatureCheckerLib.sol";
import { LibString } from "solady/utils/LibString.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract DemoERC1155 is  Ownable, ERC1155Supply, EIP712 {
    /*//////////////////////////////////////////////////////////////
                                 USING
    //////////////////////////////////////////////////////////////*/
    using LibString for *;

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    /// @notice Token has already been claimed for this fid
    error AlreadyMinted();

    /// @notice Caller provided invalid `Mint` signature
    error InvalidSignature();

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/
    uint256 public currentTokenId = 0;
    string public baseURI;
     /// @notice Address authorized to sign `Mint` messages
    address public signer;

    /// @notice Mapping tracking fids that have minted
    mapping(uint256 fid => bool) public hasMinted;

    /// @notice EIP-712 typehash for `Mint` message
    bytes32 public constant MINT_TYPEHASH =
        keccak256("Mint(address to,uint256 tokenId,uint256 fid)");

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event BaseTokenURISet(string tokenURI);
    /// @notice Emitted when a user mints through the Frame server
    event Mint(address indexed to, uint256 indexed tokenId, uint256 indexed fid);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(
        address ownerAddress_
    ) ERC1155("") {
        _initializeOwner(ownerAddress_);
        signer = ownerAddress_;

        // Update this with your own NFT collection's metadata
        baseURI = "https://www.arweave.net/";
    }

    function mint(
        address to,
        uint256 tokenId,
        uint256 fid,
        bytes calldata sig
    ) external {
        if (!_verifySignature(to, tokenId, fid, sig)) {
            revert InvalidSignature();
        }
        if (hasMinted[fid]) {
            revert AlreadyMinted();
        }

        hasMinted[fid] = true;
        emit Mint(to, tokenId, fid);
        ++currentTokenId;
        _mint(to, currentTokenId,1,"");
    }

    // Set the token URI for all tokens that don't have a custom tokenURI set.
    // Must be called by the owner given its global impact on the collection
    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
        emit BaseTokenURISet(baseURI);
    }

    // Returns the URI for a token ID
    function uri(uint256 tokenId) public view override returns (string memory) {
        // return string.concat(baseURI, tokenId.toString());
        return string.concat(baseURI,"R3YfnKXdGsx8ndtpGEHYVEi-p1qU8uPqeDdtarCuGvo?ext=png");
    }


    /// @dev EIP-712 domain name and contract version.
    function _domainNameAndVersion()
        internal
        pure
        override
        returns (string memory, string memory)
    {
        return ("DEMO FARCASTER NFT MINT", "1");
    }


    /// @dev Verify EIP-712 `Mint` signature.
    function _verifySignature(
        address to,
        uint256 tokenId,
        uint256 fid,
        bytes calldata sig
    ) internal view returns (bool) {
        bytes32 digest =
            _hashTypedData(keccak256(abi.encode(MINT_TYPEHASH, to, tokenId, fid)));
        return
            SignatureCheckerLib.isValidSignatureNowCalldata(signer, digest, sig);
    }

    receive() external payable {}
}
