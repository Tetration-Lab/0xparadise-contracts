// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "openzeppelin-contracts/contracts/utils/math/Math.sol";
import "./StuffLib.sol";
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
        uint attackerAtk, // attacker atk
        uint attackerDef, // attacker def
        uint defenderAtk, // defender atk
        uint defenderDef // defender def
    ) public pure returns (uint, uint) {
        uint attackerHPLoss = defenderAtk > attackerDef + Constants.BASE_DAMAGE
            ? defenderAtk - attackerDef
            : Constants.BASE_DAMAGE;
        uint defenderHPLoss = (attackerAtk * Constants.INITIATIVE_BONUS) /
            Constants.ONE >
            defenderDef + Constants.BASE_DAMAGE
            ? (attackerAtk * Constants.INITIATIVE_BONUS) /
                Constants.ONE -
                defenderDef
            : Constants.BASE_DAMAGE;
        return (attackerHPLoss, defenderHPLoss);
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

    // calculate buildinmg stat in sqrt scale
    function resource2Stat(
        uint progress,
        uint base,
        uint multiplier
    ) public pure returns (uint) {
        return (Math.sqrt((base + progress) / Constants.ONE) * multiplier);
    }

    function probHit(uint prob, uint randomness) public pure returns (bool) {
        return randomness % 100 < prob;
    }

    // Bonus function for harvest by individual building, returns bonus action point for that harvest
    // 1_000 = 1%
    function individualHarvestBonus(
        uint32 resource
    ) public pure returns (uint32 bonusActionPointPct) {
        return 0;
    }

    // Bonus function for harvest by community building, returns bonus action point for that harvest
    // 1_000 = 1%
    function communityHarvestBonus(
        uint32 resource
    ) public pure returns (uint32 bonusActionPointPct) {
        return 0;
    }

    // calculate normalized harvest action points
    function normalizeWithBonus(
        Resources memory plan,
        ResourcesUnit memory individualBonus,
        ResourcesUnit memory communityBonus
    ) public pure returns (Resources memory) {
        uint base = 0;
        base +=
            plan.rock +
            (plan.rock *
                (individualHarvestBonus(individualBonus.rock) +
                    communityHarvestBonus(communityBonus.rock))) /
            Constants.ONE;
        base +=
            plan.wood +
            (plan.wood *
                (individualHarvestBonus(individualBonus.wood) +
                    communityHarvestBonus(communityBonus.wood))) /
            Constants.ONE;
        base +=
            plan.fruit +
            (plan.fruit *
                (individualHarvestBonus(individualBonus.food) +
                    communityHarvestBonus(communityBonus.food))) /
            Constants.ONE;
        base +=
            plan.animal +
            (plan.animal *
                (individualHarvestBonus(individualBonus.food) +
                    communityHarvestBonus(communityBonus.food))) /
            Constants.ONE;
        base +=
            plan.fish +
            (plan.fish *
                (individualHarvestBonus(individualBonus.food) +
                    communityHarvestBonus(communityBonus.food))) /
            Constants.ONE;
        base += plan.pearl;

        return
            Resources({
                rock: uint32((plan.rock * Constants.ACTION_POINT) / base),
                wood: uint32((plan.wood * Constants.ACTION_POINT) / base),
                fruit: uint32((plan.fruit * Constants.ACTION_POINT) / base),
                animal: uint32((plan.animal * Constants.ACTION_POINT) / base),
                fish: uint32((plan.fish * Constants.ACTION_POINT) / base),
                pearl: uint32((plan.pearl * Constants.ACTION_POINT) / base)
            });
    }
}
