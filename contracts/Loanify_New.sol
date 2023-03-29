// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

contract Loanify{

    mapping(address => uint256) public creditScores;

    // Struct to hold customer data
    struct CustomerSchema {
        address customerAddress;
        uint256 creditScore;
    }

    constructor(){
        uint256 contract_balance = address(this).balance;
    }

    CustomerSchema[] public customerArray;

    // Function to add a new customer's credit score to the mapping and array
    function addCustomer(address _customer, uint256 _creditScore) public {

        // Add the customer's credit score to the mapping
        creditScores[_customer] = _creditScore;
        
        // Add the customer to the array of Customer structs
        CustomerSchema memory newCustomer = CustomerSchema({
            customerAddress: _customer,
            creditScore: _creditScore
        });

        customerArray.push(newCustomer);
    }

    function getCreditScore(address _customer) public view returns (uint256) {
        if (creditScores[_customer] != 0) {
            return creditScores[_customer];
        } else {
            return 0;
        }
    }

    


}