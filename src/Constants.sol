// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

library Constants {
    uint constant ONE = 1_000;

    uint constant ACTION_POINT = 1_000;

    uint constant FOOD_UNIT_PER_MEAT_PCT = 1_000; // 1 meat = 1 food
    uint constant FOOD_UNIT_PER_FISH_PCT = 1_000; // 1 fish = 1 food
    uint constant FOOD_UNIT_PER_FRUIT_PCT = 1_000; // 1 fruit = 1 food

    uint32 constant INITIAL_HP = 100_000;

    uint constant INITIATIVE_BONUS_PCT = 1_200; // 1200/1000 = 1.2 = 120%
    uint constant BASE_DAMAGE = 1_000;

    uint constant EFFECTIVE_MINING_RATIO = 2;
}
