// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

library Constants {
    uint constant ONE = 100;
    uint constant ONE_HUNDRED = 10_000;
    uint constant SQRT_ONE = 10;

    uint constant ACTION_POINT = 100_000;

    uint constant PERSONAL_BUILDING_DIVIDER = 100;
    uint constant COMMUNITY_BUILDING_DIVIDER = 700;

    uint constant HARVEST_BUILDING_MULTIPLIER = 250;
    uint constant SURVIVAL_BUILDING_MULTIPLIER = 150;
    uint constant ATTACK_BUILDING_MULTIPLIER = 100;
    uint constant DEFENSE_BUILDING_MULTIPLIER = 100;

    uint constant FOOD_UNIT_PER_MEAT_PCT = 100; // 1 meat = 1 food
    uint constant FOOD_UNIT_PER_FISH_PCT = 75; // 0.75 fish = 1 food
    uint constant FOOD_UNIT_PER_FRUIT_PCT = 50; // 0.5 fruit = 1 food

    uint32 constant INITIAL_HP = 10_000; // 100 HP

    uint constant INITIATIVE_BONUS_PCT = 120; // 1200/1000 = 1.2 = 120%
    uint constant BASE_DAMAGE = 100; // 1 HP

    uint constant EFFECTIVE_MINING_RATIO = 2;

    uint constant MAX_FOOD_UNIT_CONSUME = 1_000;
    uint constant MIN_FOOD_UNIT_CONSUME = 100;
    uint constant FOOD_CONSUME_PER_MAX_HEALTH_SLOPE = 1_000; // 1 food per 10 health
    uint constant HEALTH_PER_FOOD_UNIT = 500; // 1 food = 5 health

    uint constant DISASTER_BASE_DAMAGE = 100;
    uint constant DISASTER_DAY_DAMAGE_STEP = 5;
    uint constant DISASTER_BASE_CHANCE = 100; // 1%
    uint constant DISASTER_CHANCE_PER_DAY_SLOPE = 100; // 1%/d

    uint constant TREE_GROWTH_RATE_R_T = 100;
    uint constant TREE_GROWTH_RATE_FROM_FRUIT_R_F = 60;
    uint constant TREE_CAPACITY_K_T = 4_000;
    uint constant TREE_CAPACITY_FROM_FRUIT_K_F = 10_000;
    uint constant FRUIT_REGEN_RATE_LAMBDA = 800;
    uint constant ANIMAL_FRUIT_CONSUMPTION_RATE_ALPHA = 50;
    uint constant ANIMAL_REPRODUCTION_RATE_BETA = 10;
    uint constant ANIMAL_DEATH_RATE_GAMMA = 70;
    uint constant FISH_GROWTH_RATE_R_V = 50;
    uint constant FISH_CAPACITY_K_V = 5_000;
    uint constant ROCK_CAPACITY_K_R = 20_000;
    uint constant PEARL_CAPACITY_K_P = 10_000;
}
