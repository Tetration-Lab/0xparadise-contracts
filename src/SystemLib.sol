// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "openzeppelin-contracts/contracts/utils/math/Math.sol";
import "./StuffLib.sol";
import "./BonusLib.sol";
import "./Constants.sol";

library SystemLib {
    // simulate lotka volterra equation aka predator prey model
    // https://en.m.wikipedia.org/wiki/Lotka%E2%80%93Volterra_equations
    // reuturn dX, dY
    function lotkaVolterra(
        uint x, // prey
        uint y, // predator
        uint alpha, // prey growth rate
        uint beta, // predation rate
        uint gramma, // predator growth rate
        uint delta // predator decay rate
    ) public pure returns (int, int) {
        int dx = int((alpha * x) / Constants.ONE) -
            int((((beta * x) / Constants.ONE) * y) / Constants.ONE);
        int dy = int((((gramma * x) / Constants.ONE) * y) / Constants.ONE) -
            int((delta * y) / Constants.ONE);
        return (dx, dy);
    }

    // simulate logistic growth. reuturn dX
    function logisticGrowth(
        uint x, // population
        uint r, // growth rate
        uint k // carrying capacity
    ) public pure returns (uint) {
        return (((r * x) / Constants.ONE) * (k - x)) / k;
    }

    // simulate production growth with carrying capacity
    // similar to logistic growth but with different formula
    // reuturn dX
    function productionGrowth(
        uint x, // population producer
        uint y, // population target
        uint r, // growth rate
        uint k // carrying capacity
    ) public pure returns (uint) {
        return (((r * x) / Constants.ONE) * (k - y)) / k;
    }

    // simmulate player battle damage
    // return attackerHPLoss, defenderDamage
    function battleDamage(
        uint32 attackerAtk, // attacker atk
        uint32 attackerDef, // attacker def
        uint32 defenderAtk, // defender atk
        uint32 defenderDef // defender def
    ) public pure returns (uint32, uint32) {
        uint attackerHPLoss = defenderAtk > attackerDef + Constants.BASE_DAMAGE
            ? defenderAtk - attackerDef
            : Constants.BASE_DAMAGE;
        uint defenderHPLoss = (attackerAtk * Constants.INITIATIVE_BONUS_PCT) /
            Constants.ONE >
            defenderDef + Constants.BASE_DAMAGE
            ? (attackerAtk * Constants.INITIATIVE_BONUS_PCT) /
                Constants.ONE -
                defenderDef
            : Constants.BASE_DAMAGE;
        return (uint32(attackerHPLoss), uint32(defenderHPLoss));
    }

    // simulate disaster. if hit return damage in range. else return 0. cal prob by hash of block
    function disasterFunction(
        uint damageMin,
        uint damageMax,
        uint hitProb,
        uint randomness
    ) public pure returns (bool, uint) {
        if (probHit(hitProb, randomness + 420)) {
            return (
                true,
                ((randomness + 1337) % (damageMax - damageMin)) + damageMin
            );
        }
        return (false, 0);
    }

    // distribute damage to player. similar to battle damage but with different formula
    function distributeDamage(
        uint communityDef, // community def,
        uint personalDef, // personal def
        uint damage // damage to distribute
    ) public pure returns (uint) {
        uint totalDef = communityDef + personalDef;
        uint finalDamage = damage > totalDef
            ? damage - totalDef
            : Constants.BASE_DAMAGE;
        return finalDamage;
    }

    // harvest reusult per work unit
    // if low resource compare to demand, will reduce harvest and harvest per share
    // if supply higher than EFFECTIVE_MINING_RATIO x totalHarvastPoint will get full harvest.
    // otherwise will get harvest per share pernalty
    function harvestPerShare(
        uint32 supply,
        uint32 totalHarvestPoint
    ) public pure returns (uint32) {
        return
            uint32(
                Math.min(
                    supply /
                        (totalHarvestPoint * Constants.EFFECTIVE_MINING_RATIO),
                    Constants.ONE
                )
            );
    }

    function probHit(uint prob, uint randomness) public pure returns (bool) {
        return randomness % 100 < prob;
    }

    // calculate normalized harvest action points
    function normalizeWithBonus(
        Resources memory plan,
        ResourcesUnit memory individualBonus,
        ResourcesUnit memory communityBonus
    ) public pure returns (Resources memory) {
        uint base = 0;

        uint rock = (plan.rock *
            Constants.ACTION_POINT *
            (Constants.ONE_HUNDRED +
                BonusLib.individualHarvestBonus(individualBonus.rock) +
                BonusLib.communityHarvestBonus(communityBonus.rock))) /
            Constants.ONE_HUNDRED;
        uint wood = (plan.wood *
            Constants.ACTION_POINT *
            (Constants.ONE_HUNDRED +
                BonusLib.individualHarvestBonus(individualBonus.wood) +
                BonusLib.communityHarvestBonus(communityBonus.wood))) /
            Constants.ONE_HUNDRED;
        uint fruit = (plan.fruit *
            Constants.ACTION_POINT *
            (Constants.ONE_HUNDRED +
                BonusLib.individualHarvestBonus(individualBonus.food) +
                BonusLib.communityHarvestBonus(communityBonus.food))) /
            Constants.ONE_HUNDRED;
        uint animal = (plan.animal *
            Constants.ACTION_POINT *
            (Constants.ONE_HUNDRED +
                BonusLib.individualHarvestBonus(individualBonus.food) +
                BonusLib.communityHarvestBonus(communityBonus.food))) /
            Constants.ONE_HUNDRED;
        uint fish = (plan.fish *
            Constants.ACTION_POINT *
            (Constants.ONE_HUNDRED +
                BonusLib.individualHarvestBonus(individualBonus.food) +
                BonusLib.communityHarvestBonus(communityBonus.food))) /
            Constants.ONE_HUNDRED;
        uint pearl = plan.pearl * Constants.ACTION_POINT;

        base += rock;
        base += wood;
        base += fruit;
        base += animal;
        base += fish;
        base += pearl;

        return
            Resources({
                rock: uint32(rock / base),
                wood: uint32(wood / base),
                fruit: uint32(fruit / base),
                animal: uint32(animal / base),
                fish: uint32(fish / base),
                pearl: uint32(pearl / base)
            });
    }

    // calculate how many unit of food able to eat
    function calculateFoodToEat(uint32 maxHp) public pure returns (uint32) {
        // linear
        return
            uint32(
                Math.min(
                    Constants.MAX_FOOD_UNIT_CONSUME,
                    Constants.MIN_FOOD_UNIT_CONSUME +
                        (maxHp - Constants.INITIAL_HP) *
                        Constants.FOOD_CONSUME_PER_MAX_HEALTH_SLOPE
                )
            );
    }

    // calculate disaster damage
    function disasterDamage(uint day) public pure returns (uint32) {
        return
            uint32(
                Constants.DISASTER_BASE_DAMAGE *
                    (day / Constants.DISASTER_DAY_DAMAGE_STEP)
            );
    }

    // calculate whether disaster hit or not and damage
    function isDisasterHit(
        uint day,
        uint randomness
    ) public pure returns (bool, uint32) {
        uint hitChance = Constants.DISASTER_BASE_CHANCE +
            (day * Constants.DISASTER_CHANCE_PER_DAY_SLOPE);
        return (
            (randomness % Constants.ONE_HUNDRED) < hitChance,
            disasterDamage(day)
        );
    }
}
