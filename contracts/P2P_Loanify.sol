// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

contract P2PLoanify{

    //INITIALIZE A CONSTRUCTOR TO SET THE CONTRACT BALANCE TO 0 ON DEPLOYMENT.

    uint256 contractBalance;

    constructor() payable {
        contractBalance = msg.value;
    }

    address lenderAddress;
    mapping(address => uint256) public lenderBalance;

    //INITIALIZE BORROWER STATES
    address borrowerAddress;
    mapping(address => uint256) public borrowerCredit;
    mapping(address => uint256) public borrowerIncomePY;
    mapping(address => uint256) public borrowerBalance;

    // STRUCT TO HOLD BORROWER DATA
    struct borrowerSchema {
        address borrowerAddress;
        uint256 borrowerCredit;
        uint256 borrowerBalance;
        uint256 borrowerIncomePY;
    }

    //INITIALIZE OFFER STATES
    uint256 offerID;
    mapping(uint256 => address) public lender;
    mapping(uint256 => uint256) public offerAmount;
    mapping(uint256 => uint256) public offerDuration;
    mapping(uint256 => uint256) public offerRate;
    mapping(uint256 => bool) public isAvailable;
    mapping(uint256 => bool) public isMine;
    mapping(uint256 => bool) public isDeleted;
    mapping(uint256 => bool) public isDue;

    // STRUCT TO HOLD OFFER DATA
    struct offerSchema {
        address lender;
        uint256 offerID;
        uint256 offer_amount;
        uint256 lend_rate;
        uint256 lend_duration;
        uint256 lend_repayment;
        bool isAvailable;
        bool isCancelled;
        bool isDue;
    }

    //INITIALIZE OFFERS ARRAY TO HOLD ALL OFFERS
    offerSchema[] public offersArray;

    // CREATE AN INSTANCE OF THE OFFER SCHEMA TO HOLD THE CURRENT LOANS A USER HAS.
    offerSchema[] public myLoans;

    //FUNCTION TO RETURN ALL OFFERS ENCODED
    function get_offers() public view returns (bytes memory){
        // require(offersArray.length > 0,"No offers");
        return abi.encode(offersArray);
    }

    //FUNCTION TO CREATE AN OFFER
    function create_offer(uint256 _offerAmount, uint256 _loanDuration, uint256 _loanRate) public payable returns(string memory){
        
        require(_offerAmount > 0 && _loanDuration > 0 && _loanRate > 0, "Fill in the required fields" );

        //ASSIGN OFFER STATES TO PARAMETERS
        offerID++;
        lender[offerID] = msg.sender;
        offerAmount[offerID] = _offerAmount;
        offerDuration[offerID] = _loanDuration;
        offerRate[offerID] = _loanRate;
        
        //PLACE PARAMETERS IN THE STRUCT
        offerSchema memory newOffer = offerSchema({
            lender: msg.sender,
            offerID: offerID,
            offer_amount: _offerAmount,
            lend_rate:_loanRate,
            lend_duration: _loanDuration,
            lend_repayment:(_offerAmount*_loanDuration*_loanRate)/12*100,
            isAvailable:true,
            isCancelled:false,
            isDue:false
        });

        //CHECK THE OFFER ARRAY LENGTH AND STORE IT
        uint256 newOfferIndex = offersArray.length;

        //PUSH THE NEWLY CREATED OFFER
        offersArray.push(newOffer);

        //DEPOSIT THE FUNDS ON THE CONTRACT AND HOLD
        contractBalance = (contractBalance + (_offerAmount * 1 ether));

        //DEDUCT THE FUNDS FROM LENDER'S ACCOUNT
        uint256 newBalance = msg.sender.balance - _offerAmount;

        //COMPARE THE LENGTH TO THE LENGTH + 1 TO ENSURE THERE WAS A PUSH. IF NOT, RETURN AN ERROR.
        require(offersArray.length == newOfferIndex + 1, "Error creating an offer, try again");

        return "Offer Created";
    }

    //FUNCTION TO DELETE OFFER
    function delete_offer(uint256 offerId) public returns(uint256) {
        require(msg.sender == offersArray[offerId].lender, "You are not the creator of this offer.");
        bool found = false;
        for (uint256 i = 0; i < offersArray.length; i++) {         
            require(offersArray[i].offerID == offerId,"Does not exist");
            found = true;
            require(i < offersArray.length - 1,"Error");
            delete offersArray[i];
            offersArray[i] = offersArray[offersArray.length - 1];
            offersArray.pop();   
            contractBalance -= offersArray[i].offer_amount;
            uint256 newBalance = msg.sender.balance + offersArray[i].offer_amount;       
            return newBalance;      
        }     
        
        require(found, "Offer not found");
    }

    //REMOVE OFFER FROM ALL OFFERS
    function remove_offer(uint256 offerId) public{  
        for (uint256 i = 0; i < offersArray.length; i++) {         
            require(offersArray[i].offerID == offerId,"Does not exist");
            require(i < offersArray.length - 1,"Error");
            delete offersArray[i];
            offersArray[i] = offersArray[offersArray.length - 1];
            offersArray.pop();        
            break;       
        }     
    }
    function remove_my_loan(uint256 offerId) public{  
        for (uint256 i = 0; i < myLoans.length; i++) {         
            require(myLoans[i].offerID == offerId,"Does not exist");
            require(i < myLoans.length - 1,"Error");
            delete myLoans[i];
            myLoans[i] = myLoans[myLoans.length - 1];
            myLoans.pop();        
            break;       
        }     
    }

    //CREATE A SCHEMA TO HOLD ALL CUSTOMERS
    borrowerSchema[] public customerArray;

    // Function to add a new customer's credit score to the mapping and array
    function add_customer(address _customer, uint256 _creditScore, uint256 _netIncome, uint _customer_balance) public {

        // Add the customer's credit score to the mapping
        borrowerCredit[_customer] = _creditScore;
        borrowerIncomePY[_customer] = _netIncome;
        borrowerBalance[_customer] = _customer_balance;
        
        // Add the customer to the array of Customer structs
        borrowerSchema memory newCustomer = borrowerSchema({
            borrowerAddress: _customer,
            borrowerCredit: _creditScore,
            borrowerBalance: _customer_balance,
            borrowerIncomePY: _netIncome
        });

        //PUSH THE CUSTOMER TO THE NEW CUSTOMER ARRAY.
        customerArray.push(newCustomer);
    }

    //FUNCTION TO GET CREDIT SCORE OF THE PERSON APPLYING FOR LOAN
    function get_credit_score() public view returns (uint256) {

        //CHECK IF A VALUE IS RETURNED AND IF YES, RETURN THE CREDIT SCORE OF THE PERSON TRIGGERING THIS FUNCTION.
        require(borrowerCredit[msg.sender] != 0,"Error getting your credit score");
        return borrowerCredit[msg.sender];

    }

    //FUNCTION TO GET NET INCOME OF THE PERSON APPLYING FOR LOAN
    function get_net_income() public view returns (uint256) {

        //CHECK IF A VALUE IS RETURNED AND IF YES, RETURN THE NET INC0ME OF THE PERSON TRIGGERING THIS FUNCTION.
        require(borrowerIncomePY[msg.sender] != 0,"Error getting your net income");
        return borrowerIncomePY[msg.sender];

    }

    // FUNCTION TO APPLY FOR LOAN. PASS THE BORROWERS ADDRESS AND OFFER ID
    function apply_for_loan(uint256 offerID) public payable returns(string memory){
        
        //CHECK THE PERSON TRYING TO APPLY AND RETURN ERROR IF THE CREATOR IS TRYING TO APPLY...
        require(msg.sender != offersArray[offerID].lender, "You cannot apply for your own loan.");

        //CALL FUNCTION TO CHECK CREDIT SCORE AND NET INCOME OF THE PERSON APPLYING
        uint256 myCredit = get_credit_score();
        uint256 myIncome = get_net_income();

        //CHECK IF CREDIT SCORE IS ABOVE 350 AND RETURN AN ERROR IF NOT
        require(myCredit >= 300,"Your credit score is too low.");
        
        //CHECK IF THE PERSON'S INCOME IS MORE OR EQUAL TO 5 TIMES THE REPAYMENT.
        require(myIncome >= 5 * offersArray[offerID].lend_repayment, "Your income level is too low for this loan.");
        
        //MAKE THE OFFER UNAVAILABE AS IT WILL BE ASSINGED TO THIS PERSON
        offersArray[offerID].isAvailable = false;

        //ADD THE OFFER TO AN ARRAY TO HOLD ONLY LOANS THE PERSON HAS TAKEN
        myLoans.push(offersArray[offerID]);

        //REMOVE OFFER FROM ALL OFFERS ARRAY(PENDING)
        remove_offer(offerID);

        //CREDIT THE PERSON'S WALLET WITH THE AMOUNT OF THE LOAN
        msg.sender.balance + offersArray[offerID].offer_amount;

        // DEBIT THE CONTRACT THAT HELD THE MONEY
        contractBalance - offersArray[offerID].offer_amount;

        //RETURN A SUCCESS MESSAGE IF EVERYTHING WORKS.
        return "Loan Approved. Funds can now be accessed in your wallet.";

    }

    //SEND REPAYMENT TO THE CREATOR
    function repay_loan(address payable _recipient, uint256 _amount, uint256 offerId) public payable returns(uint256){
        
        require(msg.sender.balance >= _amount, "Insufficient balance");
        _recipient.transfer(_amount);
        remove_my_loan(offerId);
        
        return msg.sender.balance;

    }

}