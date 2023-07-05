// This file is part of erbb-erc20.
// Copyright (C) 2023 Simcord LLC
//
// erbb-erc20 is free software: you can redistribute it and/or
// modify it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
//
// erbb-erc20 is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with erbb-erc20. If not, see <https://www.gnu.org/licenses/>.

// SPDX-License-Identifier: GNU GPLv3
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ERBB is ERC20, Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UNPAUSER_ROLE = keccak256("UNPAUSER_ROLE");
    bytes32 public constant SERVICE_ROLE = keccak256("SERVICE_ROLE");

    uint256 public maxSupply;

    constructor(address admin, address pauser, address unpauser, address service) ERC20("Exchange Request for Bitbon", "ERBB") {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(PAUSER_ROLE, pauser);
        _grantRole(UNPAUSER_ROLE, unpauser);
        _grantRole(SERVICE_ROLE, service);

        maxSupply = 100000000 * 10**decimals();
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(UNPAUSER_ROLE) {
        _unpause();
    }

    function decimals() public pure override returns (uint8) {
        return 27;
    }

    function mint(address account, uint256 amount) external whenNotPaused onlyRole(SERVICE_ROLE) {
        require(
            totalSupply() + amount <= maxSupply,
            "mint amount exceeds max supply amount for token"
        );
        require(
            amount <= 10000 * 10**decimals(),
            "can't mint more than 10000 ERBB"
        );

        _mint(account, amount);
    }

    function burn(address account, uint256 amount) internal whenNotPaused {
        _burn(account, amount);
    }

    function transfer(address to, uint256 amount) public override whenNotPaused returns (bool) {
        if (to == address(this) || to == address(0)) {
            burn(msg.sender, amount);
            return true;
        }

        return super.transfer(to, amount);
    }
}
