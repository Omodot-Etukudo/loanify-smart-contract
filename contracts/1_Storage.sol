pragma solidity 0.8.7;

contract myFirstContract{
    uint256 myNumber;
    string name;
    string[] names;
    

    enum FreshJuiceSize{ SMALL, MEDIUM, LARGE }

    
    mapping(string => uint256) public phonenumbers;

    function addNumber(int a, int b) view public returns(int){
        int sum = a + b;
        return sum;
    }

    function changeNumber(uint256 number) public {
        myNumber = number;
    }
    function viewNumber() view public returns(uint256){
        return myNumber;
    }








    // 
    // 
    // function addName(string memory name) public{
    //     names.push(name);
    // }
    // function getName(uint256 index) view public returns(string memory){
    //     return names[index];
    // }
    // function assignNumber(string memory name, uint256 number) public {
    //     phonenumbers[name] = number;
    // }
}
