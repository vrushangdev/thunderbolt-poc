pragma solidity >=0.4.21 <0.6.0;
//admin permission contract
contract Admin {
  //admin address variable
  address admin ;
  //admin contract constructor to set admin as person who executes or deploys smart contract using msg.sender function
  constructor() public{
    admin = msg.sender;
  }
//setting acess modifier to restrict other addresses from acessing criticial functions .
  modifier onlyAdmin()
{
    require(
        msg.sender == admin,
        "Sender not Authorized."
    );
    // Do not forget the "_;"! It will
    // be replaced by the actual function
    // body when the modifier is used.
    _;
}
//Change Admin Address Or Ownership
  function changeAdmin(address _newAdmin) onlyAdmin() public {
    admin = _newAdmin;

  }
  //function to get admin retrieve current admin address from blockchain
  function getAdminAddress() public view returns (address) {
    return admin;

  }

}
//License Token Contract Start's Here

//Inheriting All The Properties And Attribute's Of Admin Contract .
contract LicenseToken is Admin {

//Now Building Proper Data Type To Store All The Attribute's Of Each License .
  struct LicenseAttributes {
    
    string registeredOn;
    string expiresOn;
    string device_hardware_id;

  }
//declaring list of our license tokens with attributes as an array .
  LicenseAttributes[] license;
//setting dictionary to store license data
//Would Look Something Like This "array Index" => "address of client"
mapping (uint256 => address) public licenseNumberToClient;
//Would Look Something Like  "Client Address" => "Total Licenses Owned By An Individual"
mapping (address => uint256) ownershipLicenseCount;


//events
//Genereate An Event When License Is Give To A Specific Address
event LicenseGiven(address account,uint256 licenseNumber);
//Generate Evenet When License Is Transfered From One Address To Another
event Transfer(address _from,address _to,uint256 _licenseNumber);
//Generate Event When Admin Approve's A New License
event Approval(address admin,address approved,uint256 licenseNumber);
//contructor
constructor() public {

}
//started to implement basic function's
//this function will return us total number of licenses

  function totalLicenses() public view returns (uint256) {
      
    return license.length;
  }
  //balanceof will return us total eth balance availaible in given eth address
  function balanceOf(address _account) public view returns (uint256 balance) {

      return  ownershipLicenseCount[_account];

  }
  //This Function Will Return Us Address Of Owner From Index Of License Token
  function ownerOf(uint256 _license_number) public view returns (address owner) {

    owner = licenseNumberToClient[_license_number];
    //.i.e owner might not be burn address : 0x0000000000000000000000000000000000000000 else everyone will get free license's
    //as we will be adding burned/expired licenses to burned address.
    require(owner != address(0));
    return  owner;

  }
//*******Crucial Financial Function To Make Transfer
//This Is onlyAdmin Functionality And Admin Can Only Make This On User Request
  function transferFrom(address _from,address _to,uint256 _license_number)onlyAdmin() public {
    //neither burn address
    require(_to!=address(0));
    //nor it should be admin address
    require(_to!=address(this));
//Now A private function will intiate this transfer after doing validation's here
    _transfer(_from,_to,_license_number);


  }

//this function is also admin only and only admin can create tokens 
  function giveLicense(address _account,string memory _registeredOn,string memory _expiresOn,string memory _hwid)onlyAdmin() public {
    //now a private function will generate license and we wil store and emit it as an event
    uint256 licenseId = _mint(_account,_registeredOn,_expiresOn,_hwid);
    emit LicenseGiven(_account,licenseId);
  }
  //to get details of complete license index
function getLicenseHardwareId(uint licenseNumber) public view returns(string memory){

  return license[licenseNumber].device_hardware_id;
}

function getLicenseRegisteredOnDate(uint licenseNumber) public view returns(string memory){

  return license[licenseNumber].registeredOn;
}
function getLicenseExpiresOnDate(uint licenseNumber) public view returns(string memory){

  return license[licenseNumber].expiresOn;
}

  //Internal Private Methods
  function _owns(uint _licenseId) internal view returns (address) {
    return licenseNumberToClient[_licenseId];

  }

//this function will create a new token with unique attributes
  function _mint(address _account,string memory _registeredOn,string memory _expiresOn,string memory _hwid) onlyAdmin() internal returns (uint256 tokenId){
    //string memory hwid = string(_hwid);
    LicenseAttributes memory licenseToken = LicenseAttributes({
      registeredOn :_expiresOn,
      expiresOn : _registeredOn ,
      device_hardware_id : _hwid
      });
      //finally lets push this newly created structure into the array 
      uint id = license.push(licenseToken) -1;
      //and now lets send it to the user we created it for
     //Sending It from msg.sender .i.e. admin to the user what we need is our address,recievers address and his unique license index
      _transfer(msg.sender,_account,id);
      return id;

  }
  //this function will transfer token from one address to another
  function _transfer(address _from,address _to,uint _licNumber)internal {
    ownershipLicenseCount[_to]++;
    licenseNumberToClient[_licNumber]=_to;
    //and if this function is not created burn address then we remove the license count on senders id
    if(_from!= address(0)){
      ownershipLicenseCount[_from]--;

    }
    emit Transfer(_from, _to, _licNumber);
  }
}
