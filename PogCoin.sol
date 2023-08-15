pragma solidity >=0.7.0 <0.9.0;

contract PogCoin {

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    string public constant name = "PogCoin";
    string public constant symbol = "POG";
    uint8 public constant decimals = 18;

    mapping(address => uint256) balances;
    mapping(uint256 => mapping (address => uint256)) cooperative_balances;
    mapping(uint256 => Cooperative) cooperatives;
    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_;

    constructor(uint256 total) {
      totalSupply_ = total * 10 ** uint256(decimals);
      balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public view returns (uint256) {
      return totalSupply_;
    }

    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint numTokens) public returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] -= numTokens;
        balances[receiver] += numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] -= numTokens;
        allowed[owner][msg.sender] -= numTokens;
        balances[buyer] += numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    struct CreateCooperativeResponse {
        uint256 cooperative_id;
        address owner;
        string name;
    }

    struct InvestResponse {
        uint256 cooperative_id;
        string cooperative_name;
        uint256 total_cooperative_balance;
        uint256 your_cooperative_balance;
    }

    struct Cooperative {
        uint256 cooperative_id;
        address owner;
        string name;
        uint256 total_balance;
    }

    function createCooperative(string calldata cooperativeName) public returns (CreateCooperativeResponse memory) {
        uint256 cooperative_id = rand();
        cooperatives[cooperative_id] = Cooperative({total_balance: 0, cooperative_id: cooperative_id, owner: msg.sender, name: cooperativeName}); 
        return CreateCooperativeResponse({cooperative_id: cooperative_id, owner: msg.sender, name: cooperativeName});
    }

    function invest(uint256 cooperative_id, uint256 numTokens) public returns (InvestResponse memory) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] -= numTokens;
        cooperatives[cooperative_id].total_balance += numTokens;
        cooperative_balances[cooperative_id][msg.sender] += numTokens;
        Cooperative memory c = cooperatives[cooperative_id]; 
        return InvestResponse({
            cooperative_id: cooperative_id,
            your_cooperative_balance: cooperative_balances[cooperative_id][msg.sender], 
            total_cooperative_balance: c.total_balance,
            cooperative_name: c.name
        });
    }

    function myCooperativeBalance(uint256 cooperative_id) public view returns (uint) {
        return cooperative_balances[cooperative_id][msg.sender];
    }

    function rand() public view returns(uint256)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number
        )));

        return (seed - ((seed / 1000) * 1000));
    }
}
