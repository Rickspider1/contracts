// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./interfaces/IMintableERC20.sol";
import "./interfaces/IBurnableERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./GAOERC20.sol";

contract AgoraToken is GAOERC20, IMintableERC20, IBurnableERC20, AccessControl {
  /**
   * @notice AccessControl role that allows other EOAs or contracts
   *     to mint tokens
   *
   * @dev Checked in mint()
   */
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  /**
   * @notice AccessControl role that allows other EOAs or contracts
   *     to burn tokens
   *
   * @dev Checked in burn()
   */
  bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

  /**
   * @dev Sets the values for {name} and {symbol}.
   *
   * The default value of {decimals} is 18. To select a different value for
   * {decimals} you should overload it.
   *
   * All two of these values are immutable: they can only be set once during
   * construction.
   */
  constructor() GAOERC20("Agora", "AGR") {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    _setupRole(MINTER_ROLE, _msgSender());
    _setupRole(BURNER_ROLE, _msgSender());
  }

  /**
   * @dev Mints new tokens to an address
   *
   * @dev Restricted by `MINTER_ROLE` role
   *
   * @param _to the address the new tokens will be minted to
   * @param _amount how many new tokens will be minted
   */
  function mint(address _to, uint256 _amount) public {
    require(hasRole(MINTER_ROLE, _msgSender()), "must have minter role to mint");

    _mint(_to, _amount);
  }

  /**
   * @dev Burns some tokens from an address
   *
   * @dev Restricted by `BURNER_ROLE` role
   *
   * @param _from the address the tokens will be burned from
   * @param _amount how many tokens will be burned
   */
  function burn(address _from, uint256 _amount) public {
    require(hasRole(BURNER_ROLE, _msgSender()), "must have burner role to burn");

    _burn(_from, _amount);
  }
}
