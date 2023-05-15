// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "./StuffLib.sol";

interface IIslander {
    function planHarvest(
        World memory w,
        IslanderInfo memory self
    ) external pure returns (ResourceObj memory);

    function planBuildCommu(
        World memory w,
        IslanderInfo memory self
    ) external pure returns (BuildingObj memory);

    function planBuildSelf(
        World memory w,
        IslanderInfo memory self
    ) external pure returns (BuildingObj memory);

    function planVisit(
        World memory w,
        IslanderInfo calldata self,
        IslanderInfo calldata others
    ) external pure returns (Action);
}
