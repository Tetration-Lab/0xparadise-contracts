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
    uint32[] kills;
    uint32[] attacks;
    uint32[] attacked;
    uint32[] heals;
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
    ResourceObj harvest;
    uint32 survival;
    uint32 protection;
    uint32 score;
    uint32 atk;
    uint32 def;
}

struct Resource {
    uint32 supply; // just suppy
    uint32 baseHarvest; // base harvest per time unit spend
    uint32 prevDemand; // demand last turn
    int32 prevSupplyChange; // supply change last turn
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
