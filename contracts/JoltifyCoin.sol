// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

/**

* test1: cap exceeded mint
    * max supply is capped with 21000000*10^18, constructor mint 10000000*10^18
    * if mint 11000000*10^18+1 again, failed, if mint 11000000*10^18, success
* test2: add minter and test mint by new minter
    * address before added to minter, mint failed
    * after add address to minter, mint success
* test3: add pauser and test pause by new minter
    * address before added to pauser, pause failed
    * after add address to pauser, pause and unpause success, and pause works fine
* test4: add/remove owner(multiple owner allowed)
    * success
*/

contract JoltifyCoin is ERC20, ERC20Burnable, Pausable, AccessControl, ERC20Capped {

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE"); // 0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); // 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6
    // default admin role bytes32: 0x0000000000000000000000000000000000000000000000000000000000000000

    // default decimal is 18
    constructor() ERC20("JoltifyCoin", "JTC") ERC20Capped(21000000 * 10 ** decimals()) { // set max supply
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        _mint(msg.sender, 10000000 * 10 ** decimals()); // mint token to owner address at begining
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    // put this func here, otherwise, inheriting ERC20Capped will be required to overwride _mint()
    function _mint(address account, uint256 amount) internal override(ERC20, ERC20Capped) {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}