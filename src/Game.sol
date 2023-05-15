// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./StuffLib.sol";
import "./IIslander.sol";
import "./Constants.sol";

contract Game {
    uint256 public randomness;
    uint public rounds;
    IIslander[] islanders;
    mapping(uint => IslanderInfo) islanderInfos;
    World world;

    constructor(IIslander[] memory _islanders, uint _randomness) {
        randomness = _randomness;
        rounds = 0;
        islanders = _islanders;
        for (uint i = 0; i < islanders.length; ++i) {
            islanderInfos[i].idx = uint8(i);
            islanderInfos[i].hp = Constants.INITIAL_HP;
            islanderInfos[i].atk = Constants.INITIAL_ATK;
            islanderInfos[i].def = Constants.INITIAL_DEF;
        }
    }

    function step(uint nStep) public {
        for (uint i = 0; i < nStep; i++) {
            harvestPhase();
            buildCommuPhase();
            buildPersonalPhase();
            visitPhase();
            worldUpdate();
        }
        // BuildingObj memory tmp;
        // try
        //     islanders[0].planBuildCommu{gas: 1_337_420_69}(
        //         world,
        //         islanderInfos[0]
        //     )
        // returns (BuildingObj memory plan) {
        //     tmp = plan;
        // } catch {}
    }

    function nextRandomness() internal returns (uint) {
        randomness = uint(keccak256(abi.encode(randomness, world)));
        return randomness;
    }

    function harvestPhase() internal {}

    function buildCommuPhase() internal {}

    function buildPersonalPhase() internal {}

    function visitPhase() internal {}

    function worldUpdate() internal {}
}
