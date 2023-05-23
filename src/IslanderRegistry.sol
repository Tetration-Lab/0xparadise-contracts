// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";

contract IslanderRegistry {
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet _islandersSet;
    mapping(string => address) _islanderOwner;
    mapping(string => address) _islanders;
    mapping(address => string) _islandersNames;

    function registerIslander(
        string calldata name,
        address islanderContract
    ) public {
        require(
            !_islandersSet.contains(_islanders[name]),
            "IslanderRegistry: Islander already registered"
        );
        _islandersSet.add(islanderContract);
        _islanders[name] = islanderContract;
        _islanderOwner[name] = msg.sender;
        _islandersNames[islanderContract] = name;
    }

    function updateIslander(
        string calldata name,
        address islanderContract
    ) public {
        require(
            _islanderOwner[name] == msg.sender,
            "IslanderRegistry: Only owner can update islander"
        );
        delete _islandersNames[_islanders[name]];
        _islandersSet.remove(_islanders[name]);
        _islanders[name] = islanderContract;
        _islandersSet.add(islanderContract);
        _islandersNames[islanderContract] = name;
    }

    function getIslander(
        string calldata name
    ) public view returns (address islanderContract) {
        return _islanders[name];
    }

    function getIslanderByIndex(
        uint index
    ) public view returns (address islanderContract) {
        return _islandersSet.at(index);
    }

    function totalIslander() public view returns (uint) {
        return _islandersSet.length();
    }

    function getIslanderOwner(
        string calldata name
    ) public view returns (address owner) {
        return _islanderOwner[name];
    }

    function getIslanderPaginated(
        uint start,
        uint pageSize
    )
        public
        view
        returns (
            address[] memory islandersAddress,
            string[] memory islandersNames
        )
    {
        uint end = start + pageSize;
        if (end > _islandersSet.length()) {
            end = _islandersSet.length();
        }
        islandersAddress = new address[](end - start);
        islandersNames = new string[](end - start);
        for (uint i = start; i < end; i++) {
            islandersAddress[i - start] = _islandersSet.at(i);
            islandersNames[i - start] = _islandersNames[_islandersSet.at(i)];
        }
    }

    // sample an amount of random islanders
    function randomIslander(
        uint amount,
        uint randomSeed
    )
        public
        view
        returns (address[] memory islanderAddress, string[] memory islanderName)
    {
        islanderAddress = new address[](amount);
        islanderName = new string[](amount);
        for (uint i = 0; i < amount; i++) {
            uint randomIndex = uint(keccak256(abi.encode(randomSeed, i))) %
                _islandersSet.length();
            islanderAddress[i] = _islandersSet.at(randomIndex);
            islanderName[i] = _islandersNames[_islandersSet.at(randomIndex)];
        }
    }
}
