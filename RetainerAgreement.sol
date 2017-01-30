
/**

Copyright Michael Rice (smartcontractslayer.com), open sourced under the MIT License.

Note that there are certain statements and opinions related to the legal effects
of certain functions and terms. These are "opinions" in the truest sense that 
they are simply the musings of the author. They have not been fully research as
of this writing nor should they ever be considered legal advice. Only a lawyer
actually looking at your unique circumstances can give you effective legal advice.

To the extent that I have time and ethically can, I'm happy to try answer 
questions at michaelrice (at) protonmail (dot) com

Also, I only know this code compiles -- not sure if it would actually work as 
I hope it will.

*/
pragma solidity ^0.4.8;

contract RetainerAgreement {
	/* address of the attorney */
	address counsel = 0;
	/* address of the client who signed 
		(might need an array to hold multiples) */
	address client = 0;
	bool clientSigned = false;
	bool attorneySigned = false;

	string terms;

	bool feePaid = false;
	uint requiredFee;
	uint fee;

	/* notice how we don't assign the client at construction so we 
	   don't violate confidentiality rules */
	function RetainerAgreement(uint _requiredFee, string _terms) {
		counsel = msg.sender;
		requiredFee = _requiredFee;
		terms = _terms;
	}

	function clientSign() {
		assignClientIfNotAssigned(msg.sender);
		clientSigned = true;
		evaluateContract();
	}

	/* this is the attorney's entry point to sign. includes a check to ensure
		that only the original counsel can sign */
	function attorneySign() {
		if (msg.sender == counsel) {
			attorneySigned = true;
		} else {
			throw;	//TODO - how to handle this more elegantly
		}
		evaluateContract();
	}

	/* notice how this will accept payment from anyone and that it will assume
		the payee is the client, unless it was previously signed by someone 
		else -- might be a ethics issue in some instances */
	function fund() payable {
		assignClientIfNotAssigned(msg.sender);
		if (msg.value == requiredFee) {
			fee = msg.value;
		} else {
			throw;
		}
		evaluateContract();
	}

	function assignClientIfNotAssigned(address _sender) private {
		if (client == 0) {
			client = _sender;
		}
	}

	function evaluateContract() private {
		if (clientSigned && attorneySigned && feePaid) {
			counsel.send(fee);
		}
	}

	function returnFundsToClient() {
		if (fee != 0) {
		    client.send(fee);
		}
	}

}