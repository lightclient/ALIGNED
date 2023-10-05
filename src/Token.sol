// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Alignment is ERC20, Ownable {
    mapping(address => bool) public isUnaligned;

    constructor() ERC20("Alignment", "ALIGN") {
        _mint(msg.sender, 18446744073709552000 * 10 ** decimals());
    }

    // aligned sends an alignment reward to an individual who has expressed an
    // aligned sentiment or performed an aligned behaviour.
    function aligned(address _addr, uint256 _amt) public onlyOwner {
        _mint(_addr, _amt);
    }

    // unaligned is used to penalize small to medium lapses in alignment.
    function unaligned(address _addr, uint256 _amt) public onlyOwner {
        _burn(_addr, _amt);
    }

    // excommunicate is used in situations where an individuals expresses
    // unaligned and shows no remorse.
    function excommunicate(address _addr) public onlyOwner {
        require(_addr != address(0), "Null address is the holy user-space burn location (aligned)");
        isUnaligned[_addr] = true;
    }

    // reconcile allows the excommunicated to regain aligned status.
    function reconcile() external payable {
        require(msg.value > 10 ether, "Tithe not sufficient");
        payable(address(0).transfer(msg.value);
        isUnaligned[msg.sender] = false;
    }

    // isUnaligned is a view-only function which allows the community to know
    // the character of the person they are interacting with.
    function isUnaligned(address _addr) public view returns (bool) {
        return isBlacklisted[_addr];
    }

    // override
    function transfer(address _to, uint256 _amt) public override returns (bool) {
        require(!isUnaligned[msg.sender], "Sender is unaligned");
        require(!isUnaligned[_to], "Recipient is unaligned");
        return super.transfer(_to, _amt);
    }

    // override
    function transferFrom(address _from, address _to, uint256 _amt) public override returns (bool) {
        require(!isUnaligned[msg.sender], "Sender is unaligned");
        require(!isUnaligned[to], "Recipient is unaligned");
        return super.transferFrom(_from, _to, _amt);
    }
}
