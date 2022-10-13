//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Old {
    address public owner;
    uint256 public currentBondTokenId = 1;

    struct BondTokenDetails {
        // Struct that holds details of the Token used to buy bonds
        uint256 tokenId;
        string tokenName;
        string tokenSymbol;
        address tokenAddress;
        uint256 tokenUsdValue;
        uint256 oldValueOfToken; // The value of the token in OLD
        uint256 oldTokenDiscount; // Discount given to purchase an OLD Token
        uint256 bondLockDuration; // Time the Bond is locked for
    }

    struct BondPosition {
        // Struct that documents individual Bond Purchase Positions
        uint256 positionId;
        address bondPositionHolderWalletAddress;
        string bondTokenName;
        string bondTokenSymbol;
        uint256 amountOfBondInUsd;
        uint256 dateOfBond;
        bool open; // Shows if this Bond Position is still open or not
    }

    string[] public bondTokenSysmbols; // Array that stores the symbols of all tokens that can be used for bonds

    mapping(string => BondTokenDetails) public bondTokens; // This maps the symbol of each token to the token struct of that particular token
    uint256 totalOldTokensMinted; // Number of Reward Token or OLD token minted or purchansed by users

    uint256 public currentBondPositionId = 1;
    address public oldTokenAddress;
    uint256 public oldTokenUsdValue;

    mapping(uint256 => BondPosition) public positions; // Mapping the position Id to a particular Bond/BondPosition
    mapping(address => uint256[]) public positionIdByAddress; // Map of an array of Position Ids to the address of the user who opened the bond position
    mapping(string => uint256) public totalNumberOfToken; // Map that gives the total amount of a token that was used to purchase OLD Token

    constructor() payable {
        owner = msg.sender;
    }

    function updateOldTokenDetails(address _oldTokenAddress, uint256 _oldTokenUsdValue)
        external
        onlyOwner
    {
        oldTokenAddress = _oldTokenAddress; // This function updates the address value of the OLDtoken
        oldTokenUsdValue = _oldTokenUsdValue; // This function updates the price of the OldToken...Being used for Dev Purpose
    }

    function calculateBondDiscount(
        string calldata symbol,
        uint256 tokenAmount,
        uint256 discount
    ) public view returns (uint256) {
        return (bondTokens[symbol].oldValueOfToken *
            tokenAmount +
            ((bondTokens[symbol].oldValueOfToken * tokenAmount * discount) / 10000)); // Making use of 10,000 as 100
        // This function takes into account the discount add gives the total amount of Old token to be sent to a user
    }

    function addBondToken(
        string calldata name,
        string calldata symbol,
        address tokenAddress,
        uint256 usdValue,
        uint256 discount,
        uint256 lockDuration
    ) external onlyOwner {
        // Function to add a particular token to be able to purchace the Old
        // Token at a discount
        bondTokenSysmbols.push(symbol);

        bondTokens[symbol] = BondTokenDetails(
            currentBondTokenId,
            name,
            symbol,
            tokenAddress,
            usdValue,
            (usdValue / oldTokenUsdValue),
            discount,
            lockDuration
        );
    }

    function bond(string calldata symbol, uint256 tokenQuantity) external {
        require(bondTokens[symbol].tokenId != 0, "This token cannot be bonded"); // To make sure that only tokens allowed by the owner can be bonded
        uint256 discountOldAmount = calculateBondDiscount(
            symbol,
            tokenQuantity,
            bondTokens[symbol].oldTokenDiscount
        ); // Calulation of the discount amount to be sent
        IERC20(bondTokens[symbol].tokenAddress).transferFrom(
            msg.sender,
            address(this),
            tokenQuantity
        ); // Function to transfer the token from the user to the contract

        IERC20(oldTokenAddress).transferFrom(address(this), msg.sender, discountOldAmount);

        positions[currentBondPositionId] = BondPosition(
            currentBondPositionId,
            msg.sender,
            bondTokens[symbol].tokenName,
            symbol,
            bondTokens[symbol].tokenUsdValue * tokenQuantity,
            block.timestamp,
            true
        );

        positionIdByAddress[msg.sender].push(currentBondPositionId);
        currentBondPositionId += 1;
    }

    function calculateNumberDays(uint256 createdDate) public view returns (uint256) {
        return (block.timestamp - createdDate) / 60 / 60 / 24; // Returns number of days the Token was staked for
    }

    modifier onlyOwner() {
        // Modifier that allows only the owner of the contract to perfor a function
        require(owner == msg.sender, "Only owner may call this function");
        _;
    }
}
