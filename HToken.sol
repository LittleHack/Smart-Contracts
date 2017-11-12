pragma solidity ^0.4.11;

import "../installed_contracts/zeppelin/contracts/token/StandardToken.sol";

contract HToken is BurnableToken {

	string public constant name = "HToken";
	string public constant symbol = "HT";
	uint public constant decimals = 3;
	uint public constant MAX_TOKENS = 10 * 1e7 * 1e3; // 10 million tokens, 3 decimals

	adress public manager;

	mapping (adress => bool[]) receivedToken;

	// Constructor

	function HToken(uint256 _totalSupply, uint startTime) {
		manager = msg.sender;
		totalSupply = _totalSupply;
		startTime = now;
	}

	modifier hasReceivedTokens() {
		require(!receivedToken(msg.sender));
		_;
	}

	modifier distributionHasntEnded() {
		require(!(now >= startTime + 7 days));
		_;
	}

	modifier distributionHasEnded() {
		require(now >= startTime + 7 days);
		_;
	}

	modifier onlyManager() {
		require(msg.sender == manager);
		_;
	}

	//ERC20 functions

	function transfer(address _to, uint _value) distributionHasEnded()  returns (bool success) {
	        super.transfer(_to, _value);
	}
	
	function transferFrom(adress _from, address _to, uint _value) distributionHasEnded()  returns (bool success) {
	        super.transfer(_from, _to, _value);
	}

	function approve(address _spender, uint _value) distributionHasEnded() returns (bool success) {
		super.approve(_spender, _value);
	}

	// Calculation of token bonus -
	// 20% first day,
	// 15% second day, etc.

	function bonusTokens() constant returns (uint8) {
		if(now >= startTime + 4 days) {
			return 0;
		} else if(now >= startTime + 3 days) {
			return 5; 
		} else if(now >= startTime + 2 days) {
			return 10;
		} else if(now >= startTime + 1 days) {
			return 15;
		} else {
			return 20;
		}
	}

	function receiveTokens(uint _value) distributionHasntEnded() hasReceivedTokens(msg.sender) payable {
		balances[msg.sender] += 100 + bonusTokens();
		balances[owner] += 20;
		receivedToken[msg.sender] = true;
	}

	// Burn a specific amount of tokens

	function burn(uint256 _value) onlyManager() distributionHasEnded() {
		super.burn(_value);
	}

}
