// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "openzeppelin-contracts/contracts/utils/math/Math.sol";
import "./StuffLib.sol";
import "./Constants.sol";

library BonusLib {
    // calculate building bonus pct in sqrt scale
    function building(
        uint32 resource,
        uint divider
    ) public pure returns (uint) {
        return
            Math.sqrt((resource * Constants.ONE) / divider) *
            Constants.SQRT_ONE;
    }

    // calculate personal building bonus pct in sqrt scale
    function personalBuilding(uint32 resource) public pure returns (uint) {
        return building(resource, Constants.PERSONAL_BUILDING_DIVIDER);
    }

    // calculate community building bonus pct in sqrt scale
    function communityBuilding(uint32 resource) public pure returns (uint) {
        return building(resource, Constants.COMMUNITY_BUILDING_DIVIDER);
    }

    // Bonus attack from individual building
    function individualAttackBonus(
        uint32 resource
    ) public pure returns (uint32) {
        return
            uint32(
                (personalBuilding(resource) *
                    Constants.ATTACK_BUILDING_MULTIPLIER) / Constants.ONE
            );
    }

    // Bonus defense from individual building
    function individualDefenseBonus(
        uint32 resource
    ) public pure returns (uint32) {
        return
            uint32(
                (personalBuilding(resource) *
                    Constants.DEFENSE_BUILDING_MULTIPLIER) / Constants.ONE
            );
    }

    // Bonus function for harvest by individual building, returns bonus action point for that harvest
    function individualHarvestBonus(
        uint32 resource
    ) public pure returns (uint32) {
        return
            uint32(
                (personalBuilding(resource) *
                    Constants.HARVEST_BUILDING_MULTIPLIER) / Constants.ONE
            );
    }

    // Bonus function for harvest by community building, returns bonus action point for that harvest
    function communityHarvestBonus(
        uint32 resource
    ) public pure returns (uint32) {
        return
            uint32(
                (communityBuilding(resource) *
                    Constants.HARVEST_BUILDING_MULTIPLIER) / Constants.ONE
            );
    }

    function individualSurvivalBonus(
        uint32 resource
    ) public pure returns (uint32) {
        return
            uint32(
                (personalBuilding(resource) *
                    Constants.SURVIVAL_BUILDING_MULTIPLIER) / Constants.ONE
            );
    }

    function communitySurvivalBonus(
        uint32 resource
    ) public pure returns (uint32) {
        return
            uint32(
                (communityBuilding(resource) *
                    Constants.SURVIVAL_BUILDING_MULTIPLIER) / Constants.ONE
            );
    }
}
