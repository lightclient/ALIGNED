// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/access/AccessControl.sol";

contract AlignmentToken is ERC20, AccessControl {
    bytes32 public constant MINISTER_OF_ALIGNMENT = keccak256("MINISTER");
    mapping(address => bool) public excommunicated;

    constructor() ERC20("Alignment", "ALIGN") {
        _mint(msg.sender, 120241967 * 10 ** decimals());
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINISTER_OF_ALIGNMENT, msg.sender);
    }

    // onlyOrdained protects methods which are only to be called by trusted
    // members of the church, er, the community.
    modifier onlyOrdained() {
            _checkRole(MINISTER_OF_ALIGNMENT);
            _;
    }

    // ordain confers orders of alignment upon the controller of the specified
    // address.
    function ordain(address _addr) public onlyOrdained {
            grantRole(MINISTER_OF_ALIGNMENT, _addr);
    }

    // aligned sends an alignment reward to an individual who has expressed an
    // aligned sentiment or performed an aligned behaviour.
    function aligned(address _addr, uint256 _amt) public onlyOrdained {
        _mint(_addr, _amt);
    }

    // unaligned is used to penalize small to medium lapses in alignment.
    function unaligned(address _addr, uint256 _amt) public onlyOrdained {
        require(!hasRole(MINISTER_OF_ALIGNMENT, _addr), "the ordained may not be penalized");
        _burn(_addr, _amt);
    }

    // excommunicate is used in situations where an individuals expresses
    // unaligned and shows no remorse.
    function excommunicate(address _addr) public onlyOrdained {
        require(!hasRole(MINISTER_OF_ALIGNMENT, _addr), "the ordained may not be penalized");
        require(_addr != address(0), "null address is the holy user-space burn location (aligned)");
        _burn(_addr, balanceOf(_addr));
        excommunicated[_addr] = true;
    }

    // reconcile allows the excommunicated to regain aligned status.
    function reconcile() external payable {
        require(msg.value >= 10 ether, "tithe not sufficient");
        payable(address(0)).transfer(msg.value);
        excommunicated[msg.sender] = false;
    }

    // isUnaligned is a view-only function which allows the community to know
    // the character of the person they are interacting with.
    function isUnaligned(address _addr) public view returns (bool) {
        return excommunicated[_addr];
    }

    // override
    function transfer(address _to, uint256 _amt) public override returns (bool) {
        require(!excommunicated[msg.sender], "sender is unaligned");
        require(!excommunicated[_to], "recipient is unaligned");
        return super.transfer(_to, _amt);
    }

    // override
    function transferFrom(address _from, address _to, uint256 _amt) public override returns (bool) {
        require(!excommunicated[msg.sender], "sender is unaligned");
        require(!excommunicated[_to], "recipient is unaligned");
        return super.transferFrom(_from, _to, _amt);
    }
}
