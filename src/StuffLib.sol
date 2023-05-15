// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

enum Action {
    Attack,
    Heal,
    Nothing
}

struct IslanderInfo {
    uint8 idx;
    uint256 hp;
    uint256 atk;
    uint256 def;
    uint32 food;
    uint32 wood;
    uint32 rock;
    uint32 pearl;
    BuildingObj buildingLevel;
    ResourceObj[] harvestPlan;
    BuildingObj[] commuPlan;
    int256[] attacksCount;
    int256[] attackedCounts;
    int256[] healCounts;
}

struct ResourceObj {
    uint32 rock;
    uint32 wood;
    uint32 fruit;
    uint32 animal;
    uint32 fish;
    uint32 pearl;
}

struct BuildingObj {
    uint32 survival;
    uint32 protection;
    ResourceObj harvest;
    uint32 score;
    uint32 atk;
    uint32 def;
}

struct Resource {
    uint supply; // just suppy
    uint baseHarvest; // base harvest per time unit spend
    int dSupplyTm1; // supply change last turn
    int demandTm1; // demand last turn
}

struct World {
    BuildingObj buildingLevel;
    Resource rock;
    Resource wood;
    Resource fruit;
    Resource animal;
    Resource fish;
    Resource pearl;
}
