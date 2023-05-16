// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

enum Action {
    Attack,
    // Heal,
    Nothing
}

struct IslanderInfo {
    uint8 idx;
    uint32 hp;
    uint32 pearl;
    uint32 dayLived;
    ResourcesUnit resources;
    Buildings buildings;
    Resources[] harvestPlan;
    Buildings[] communityBuildingPlan;
    Buildings[] personalBuildingPlan;
    uint32[] kills;
    uint32[] attacks;
    uint32[] attacked;
    uint32[] heals;
}

struct ResourcesUnit {
    uint32 rock;
    uint32 wood;
    uint32 food;
}

struct Resources {
    uint32 rock;
    uint32 wood;
    uint32 fruit;
    uint32 animal;
    uint32 fish;
    uint32 pearl;
}

struct Buildings {
    ResourcesUnit harvest; // Wood
    uint32 survival; // Wood
    uint32 protection; // Wood
    uint32 statue; // Rock
    uint32 atk; // Rock
    uint32 def; // Rock
}

struct Resource {
    uint32 supply; // just suppy
    // uint32 baseHarvest; // base harvest per time unit spend
    uint32 prevHarvest; // harvest last turn
    uint32 prevRegen; // regen last turn
}

struct World {
    Buildings buildings;
    Resource rock;
    Resource wood;
    Resource fruit;
    Resource animal;
    Resource fish;
    Resource pearl;
}
