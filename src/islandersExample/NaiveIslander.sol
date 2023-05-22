// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "../IIslander.sol";

contract NaiveIslander is IIslander {
    function planHarvest(
        World memory,
        IslanderInfo memory
    ) external pure override returns (Resources memory) {
        // spend time equally on all resources
        return Resources(10, 10, 10, 10, 10, 10);
    }

    function planCommunityBuild(
        World memory,
        IslanderInfo memory self
    ) external pure override returns (Buildings memory) {
        uint32 woodPerStuff = self.resources.wood / 10;
        uint32 rockPerStuff = self.resources.rock / 6;
        return
            Buildings(
                ResourcesUnit(woodPerStuff, woodPerStuff, woodPerStuff),
                woodPerStuff,
                woodPerStuff,
                rockPerStuff,
                rockPerStuff,
                rockPerStuff
            );
    }

    function planPersonalBuild(
        World memory,
        IslanderInfo memory self
    ) external pure override returns (Buildings memory) {
        uint32 woodPerStuff = self.resources.wood / 5;
        uint32 rockPerStuff = self.resources.rock / 3;
        return
            Buildings(
                ResourcesUnit(woodPerStuff, woodPerStuff, woodPerStuff),
                woodPerStuff,
                woodPerStuff,
                rockPerStuff,
                rockPerStuff,
                rockPerStuff
            );
    }

    function planVisit(
        World memory,
        IslanderInfo calldata,
        IslanderInfo calldata,
        uint32,
        uint32
    ) external pure override returns (Action) {
        // never attack
        return Action.Nothing;
    }
}
