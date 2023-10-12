// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract SimpleNameRegister {
    //Map an address to a name to identify current holder
    mapping(string => address) public holder;

    //Emit event when a name is registered (transaction is written into the blockchain)
    event Register(address indexed holder, string name);

    //Emit event when a name is released (transaction is written into the blockchain)
    event Release(address indexed holder, string name);

    //User can register an available name
    function registerName(string calldata name) external {
        require(holder[name] == address(0), "Name already registered"); //address(0) means 0x... and 0x... etc
        holder[name] = msg.sender;
        emit Register(msg.sender, name);
    }

    //Holder can release a name, making it available
    function releaseName(string calldata name) external {
        require(holder[name] == msg.sender, "Not your name");
        delete holder[name];
        emit Release(msg.sender, name);
    }
}
