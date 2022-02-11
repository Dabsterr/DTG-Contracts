// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "../contracts/CountersUpgradeable.sol";
import "../contracts/HeroCap.sol";

contract Champion is Initializable, ERC721Upgradeable, ERC721EnumerableUpgradeable, PausableUpgradeable, OwnableUpgradeable, UUPSUpgradeable , HeroCap , ERC721URIStorageUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _tokenIdCounter;
    bool internal _isMintActive;
    uint256 internal _OGCap;
    string private baseURI;
    uint256 internal _fee;


    event MintFeeTransfer(
        address indexed _from,
        address indexed _to,
        uint _value
        );


    modifier _checkMintActive() {
        require(_isMintActive,"Mint: Minting is not active");
        _;
        }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize() initializer public {
        __ERC721_init("champion", "CHAMP");
        __ERC721Enumerable_init();
        __Pausable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
        __HeroCap_init(1000);
        __MintStatus_init(false);
        __OGCap_init(30);
        __ERC721URIStorage_init();
        _tokenIdCounter.increment();
        __Fee_init(1000);
    }

    /**
     * @dev External Functions
     */

    function setFee(uint256 fee)
        external
        onlyOwner {
            require(fee > 0 , "Fee: Must be greater than 0");
            _fee = fee * 10 ** 18;
        }

    function mintFee()
        view
        external
        returns (uint256) {
            return _fee;
        }

    function checkMintActive()
        view
        external
        returns (bool) {
            return _isMintActive;
        }

    /// @dev sets new base URI
    function setBaseURI(string memory baseURI_)
        external {
        baseURI = baseURI_;
        }

    /// @dev Main minting function
    function safeMint(address to)
        external
        payable
        _checkMintActive
        {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            address payable owner = payable(owner());

            require(msg.value == _fee, "Mint: Incorrect Value Sent");
            require(tokenId <= _cap,"Mint: Supply Cap has been reached");
            (bool sent,) = owner.call{value: msg.value}("");
            require(sent, "Failed to send Ether");

            _safeMint(to, tokenId);

            emit MintFeeTransfer(msg.sender, owner, msg.value);
        }
    
    /// @dev Minting function for reserved Champions
    function preMintOG(address to)
        external
        onlyOwner {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();

            require(tokenId <= _OGCap , "Mint: OG cap has been reached");

            _safeMint(to, tokenId);
        }

    /**
     * @dev Public Functions
     */
    
    ///@dev Returns the cap on the OG tokens to be minted.

    function OGCap()
        public
        view
        virtual
        returns (uint256) {
            return _OGCap;
        }

    /// @dev sets mint activity similar to pause()

    function setMintActivity (bool isMintActive)
        public
        onlyOwner
        {
            _isMintActive = isMintActive;
        }

    function pause()
        public
        onlyOwner
        {
        _pause();
        }

    function unpause()
        public
        onlyOwner
        {
            _unpause();
        }

    /// @dev increases the maxiumum cap

    function increaseCapBy(uint256 amount)
        public
        onlyOwner
        {
            _increaseCapBy(amount);
        }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override (
            ERC721Upgradeable,
            ERC721EnumerableUpgradeable
            )
        returns (bool) {
            return super.supportsInterface(interfaceId);
        }

    function tokenURI(uint256 tokenId)
        public
        view
        override (
            ERC721Upgradeable,
            ERC721URIStorageUpgradeable)
        returns (string memory) {
            return super.tokenURI(tokenId);
        }

    /**
     *   @dev internal functions
     */
    
    function __MintStatus_init(bool isMintActive)
        internal
        onlyInitializing
        {
            _isMintActive = isMintActive;
        }

    function __OGCap_init(uint256 ogCap)
        internal 
        onlyInitializing
        {
            _OGCap = ogCap;
        }

    function __Fee_init(uint256 _Fee)
        internal
        onlyInitializing
        {
            _fee = _Fee * 10 ** 18;
        }

    function _baseURI()
        internal
        pure
        override
        returns (string memory)
        {
            return "https://test.com/";
        }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(
            ERC721Upgradeable,
            ERC721EnumerableUpgradeable
            )
        {
            super._beforeTokenTransfer(from, to, tokenId);
        }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
        {}

    function _burn(uint256 tokenId)
        internal
        override(
            ERC721Upgradeable,
            ERC721URIStorageUpgradeable)
        {
            super._burn(tokenId);
        }

}
