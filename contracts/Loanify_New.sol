// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

contract Loanify{
    address customerAddress;
    mapping(address => uint256) public creditScore;
    mapping(address => uint256) public customer_netIncomepm;
    mapping(address => uint256) public customer_balance;

    uint256 contract_balance;
    // Struct to hold customer data
    struct CustomerSchema {
        address customerAddress;
        uint256 creditScore;
        uint256 customer_netIncomepm;
        uint256 customer_balance;
    }

    constructor(){

        //Set the contract to hold a certain amount when deployed ie. 100
        contract_balance = 100;
        

    }

    CustomerSchema[] public customerArray;

    // Function to add a new customer's credit score to the mapping and array
    function addCustomer(address _customer, uint256 _creditScore, uint256 _netIncome, uint256 _customer_balance) public {

        // Add the customer's credit score to the mapping
        creditScore[_customer] = _creditScore;
        customer_netIncomepm[_customer] = _netIncome;
        customer_balance[_customer] = _customer_balance;
        
        // Add the customer to the array of Customer structs
        CustomerSchema memory newCustomer = CustomerSchema({
            customerAddress: _customer,
            creditScore: _creditScore,
            customer_balance: _customer_balance,
            customer_netIncomepm: _netIncome
        });

        customerArray.push(newCustomer);
    }

    function getCreditScore() public view returns (uint256) {

        require(creditScore[msg.sender] != 0,"Error getting your credit score");
        return creditScore[msg.sender];

    }

    function getNetIncome() public view returns (uint256) {

        require(customer_netIncomepm[msg.sender] != 0,"Error getting your net income");
        return customer_netIncomepm[msg.sender];

    }

    function requestLoan(address _customer, uint256 loan_amount, uint256 loan_duration) public returns(uint256){

            uint256 credit = getCreditScore();
            uint256 net = getNetIncome();

            require(credit >= 350 , "Credit score too low");
            require(loan_amount <= contract_balance , "You cannot request for this amount");

            uint256 interest = (loan_amount * loan_duration * 5) / 1200;
            uint256 repaymentpm = loan_amount + interest/ loan_duration;

            require(net >= 5 * repaymentpm , "You're net income is too low for this loan amount. Try reducing it your loan request");
            
            sendFunds(loan_amount);

    }

    function sendFunds(uint256 _loan_amount) public payable{

        customer_balance[msg.sender]+= _loan_amount;
        contract_balance-=_loan_amount;
        uint256 new_balance = contract_balance - _loan_amount;

        require(contract_balance - _loan_amount == new_balance, "Error sending funds");

    }

}