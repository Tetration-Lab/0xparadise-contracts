// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "./StuffLib.sol";
import "./IIslander.sol";

contract Game {
    event Dead(uint8 idx); 
    event Attack(uint8 idx, uint8 targetIdx, uint damageAtk, uint damageDef); `
    event Heal(uint8 idx, uint8 targetIdx, uint heal);
    event BuildCommu(uint8 idx, BuildingObj plan);
    event BuildPersonal(uint8 idx, BuildingObj plan);
    event Harvest(uint8 idx, ResourceObj harvest);
    event Disaster(uint damage);
    event WorldUpdate(World world);

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
            islanderInfos[i].hp = 1000;
            islanderInfos[i].atk = 10;
            islanderInfos[i].def = 10;
            for (uint j = 0; j < islanders.length; ++j) {
                islanderInfos[i].attacksCount.push(0);
                islanderInfos[i].attackedCounts.push(0);
                islanderInfos[i].healCounts.push(0);
            }
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