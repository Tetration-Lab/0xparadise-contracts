// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "./StuffLib.sol";

interface IIslander {
    function planHarvest(
        World memory w,
        IslanderInfo memory self
    ) external pure returns (Resources memory);

    function planCommunityBuild(
        World memory w,
        IslanderInfo memory self
    ) external pure returns (Buildings memory);

    function planPersonalBuild(
        World memory w,
        IslanderInfo memory self
    ) external pure returns (Buildings memory);

    function planVisit(
        World memory w,
        IslanderInfo calldata self,
        IslanderInfo calldata others
    ) external pure returns (Action);
}
