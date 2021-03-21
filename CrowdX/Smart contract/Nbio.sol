pragma solidity ^0.6.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract NBio is ERC721 {
    
     // address of the owner
        address public Owner;
    
     // token on sale
        IERC20 public Btoken;

    // decimal value
       uint constant DValue = 10**18;
        
     // face value of each bond we will issue is fixed for now, since we are 
     // making the bond for sinle token(matic). In future we will have differnt face value
    // for differnet type of bond
        uint public FaceValue = 3;

    // time at which bond matures
        uint MaturityTime = 3 days;

     // Token Id
        uint TokenId = 999;

    // Participants
        address [] public Participants;

    // mapping of participants to bool for checking participation
       mapping(address => bool) isParticpant;

     // mapping of bondOwner to bond-issue date
        mapping(address => uint) IssueTime;

     // mapping of investor to its share
        mapping(address => uint) public shares_of_investor;
     
     constructor(address _btoken) ERC721("IBOND", "IBO") public {
         
         Owner = msg.sender;
         Btoken = IERC20(_btoken);
         
         
     }
     
     // modifier to verify, wether it  is owner or not
         modifier OnlyOwner(){
             
             require(msg.sender == Owner, "Not an Owner");
             _;
             
         }
         
    //
    
 // deposit the token to issue the bond
         
    function deposit( uint No_of_bond_to_issue, string calldata _uri) external payable{
        
        require(msg.value % 1 == 0, "Deposit Amount in MultiPle of Face Value");
        uint shares = msg.value / DValue ;
        
        shares_of_investor[msg.sender] += shares;
        
        for(uint i = 0; i < No_of_bond_to_issue; i++){
            _safeMint(msg.sender, TokenId );
             _setTokenURI(TokenId, _uri); 
             TokenId++;

            
           }

        IssueTime[msg.sender] = now; 
        Participants.push(msg.sender); 
        isParticpant[msg.sender] = true; 
    }  
   

   //  function  to claim the locked token 
    function Claim_Your_token(uint _TokenId) external{

        require(isParticpant[msg.sender] == true, "Not a Participant");
        require(ownerOf(_TokenId) == msg.sender, "not an owner of this token");

         // maturity date can be quarterly or yearly
        require(IssueTime[msg.sender] > 1 minutes, "not reached Maturity date");
    
        
        uint Amount = shares_of_investor[msg.sender] / DValue;
        
        // burning the ERC721token
        
        
           _burn(_TokenId);
           
        Btoken.transfer(msg.sender, Amount*DValue);
        
    }
     
    function getBondUri(uint Id) external view returns (string memory){
        
         require(ownerOf(Id) == msg.sender, "not an owner of this token");
         
         return  tokenURI(Id);
         
        
    }
    
    function balance() external view  returns(uint) {

        return address(this).balance;

    }

         
     
}