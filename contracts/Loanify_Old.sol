// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

contract Loanify {

  address public borrowerAddress;
  uint256 public loanAmount;
  uint256 public interestRate;
  uint256 public loanDuration;
  string  public loanStatus;
  
  // Constructor function sets the borrower's Ethereum address

//   constructor(address _borrowerAddress) {
//       borrowerAddress = _borrowerAddress;
//   }

//   Function for requesting a loan
  function requestLoan(uint256 _loanAmount, uint256 _loanDuration) public returns (string memory) {
      
      if(address(this).balance > loanAmount){

        interestRate= calculateInterestRate(_loanDuration, _loanAmount);
        loanAmount = _loanAmount;
        loanDuration = _loanDuration;  
        loanStatus = "pending";

      }

      else{
          return "We currently do not have enough ETH, check again later.";
      }
      
  }
  
  // Function for calculating the interest rate based on loan duration and amount
  function calculateInterestRate(uint256 _loanDuration, uint256 _loanAmount) internal returns (uint256) {
       
        uint256 repaymentAmount;

        if (_loanDuration >= 30) {
            interestRate = 5;
        } else {
            interestRate = _loanDuration * 5 / 30;
        }

        repaymentAmount = _loanAmount * (100 + interestRate) / 100;

        return interestRate;
  }
  


  // Function for verifying the borrower's creditworthiness
  function verifyCreditworthiness() public view returns (bool) {
      // Replace with actual creditworthiness verification logic
      // Return true if credit score is above a certain threshold, false otherwise
      return true;
  }
  
    // Function for releasing funds to the borrower
    function releaseFunds() public {
        // require(loanStatus = "approved", "Loan has not been approved yet.");
        // Transfer the loan amount to the borrower's Ethereum address
        // Replace with actual transfer function
        loanStatus = "funds released";
    }
  
    // Function for checking the status of the loan
    function checkLoanStatus() public view returns (string memory) {
        return loanStatus;
    }




}
