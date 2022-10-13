//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OLDToken is ERC20 {
    address[] public owner;
    mapping(address => bool) public Owners;

    constructor() ERC20("Old", "OLD") {
        owner.push(msg.sender);
        Owners[msg.sender] = true;
    }

    function check(address _owner) public view returns (bool) {
        return Owners[_owner];
    }

    function addOwner(address _newOwner) external onlyOwner {
        owner.push(_newOwner);
        Owners[_newOwner] = true;
    }

    function getOwners() public view returns (address[] memory) {
        return owner;
    }

    function mint(address account_, uint256 amount_) external onlyOwner {
        _mint(account_, amount_);
    }

    modifier onlyOwner() {
        require(check(msg.sender) == true, "Only owner may call this function");
        _;
    }
}
