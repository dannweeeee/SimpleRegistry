// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SimpleNameRegister.sol";


abstract contract StateZero is Test {
    SimpleNameRegister public simpleNameRegister;
    address user;

    function setUp() public virtual {
        simpleNameRegister = new SimpleNameRegister();
        user = address(1);
        vm.label(user, "user");
    }
}

contract StateZeroTest is StateZero {
    
    //negative test
    function testCannotRelease(string memory testString) public {
        console2.log("Cannot release a name that you do not hold");
        vm.prank(user);
        vm.expectRevert(bytes("Not your name"));
        simpleNameRegister.releaseName(testString);
    }

    //positive test
    function testRegister(string memory testString) public {
        console2.log("User registers a name!");
        vm.prank(user);
        simpleNameRegister.registerName(testString);
        bool success = (user == simpleNameRegister.holder(testString));
        assertTrue(success, "User is the holder of the name");
    } 
}

abstract contract StateRegistered is StateZero {
    address adversary;
    string name;

    function setUp() public override {
        super.setUp();
        adversary = address(2);
        vm.label(adversary, "adversary");

        //state transition
        name = 'whale';
        vm.prank(user);
        simpleNameRegister.registerName(name);
    }
}

contract StateRegisteredTest is StateRegistered {
    function testAdversaryCannotRegisterName() public {
        console2.log("Adversary cannot register name belonging to User");
        vm.prank(adversary);
        vm.expectRevert(bytes("Not your name"));
        simpleNameRegister.releaseName(name);
    }

    function testAdversaryCannotReleaseName() public {
        console2.log("Adversary cannot release name belonging to User");
        vm.prank(adversary);
        vm.expectRevert(bytes("Not your name"));
        simpleNameRegister.releaseName(name);
    }

    function testUserCannotReleaseOwnerName() public {
        console2.log("User cannot release name that he already holds");
        vm.prank(adversary);
        vm.expectRevert(bytes("Not your name"));
        simpleNameRegister.releaseName(name);
    }

    function testUserRelease() public {
        console2.log("User releases name that he holds");
        vm.prank(user);
        simpleNameRegister.releaseName(name);
        bool success = (address(0) == simpleNameRegister.holder(name));
        assertTrue(success, "User is the holder of the name");
    }
}