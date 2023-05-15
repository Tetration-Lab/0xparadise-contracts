// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "openzeppelin-contracts/contracts/utils/math/Math.sol";

library SystemLib {
    uint constant ONE = 1_000;
    uint constant BASE_DAMAGE = 1_000;
    uint constant INITIATIVE_BONUS = 1_200;

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
        int dx = int((alpha * x) / ONE) - int((((beta * x) / ONE) * y) / ONE);
        int dy = int((((gramma * x) / ONE) * y) / ONE) - int((delta * y) / ONE);
        return (dx, dy);
    }

    // simulate logistic growth. reuturn dX
    function logisticGrowth(
        uint x, // population
        uint r, // growth rate
        uint k // carrying capacity
    ) public pure returns (uint) {
        return (((r * x) / ONE) * (k - x)) / k;
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
        return (((r * x) / ONE) * (k - y)) / k;
    }

    // simmulate player battle damage
    // return attackerHPLoss, defenderDamage
    function battleDamage(
        uint attackerAtk, // attacker atk
        uint attackerDef, // attacker def
        uint defenderAtk, // defender atk
        uint defenderDef // defender def
    ) public pure returns (uint, uint) {
        uint attackerHPLoss = defenderAtk > attackerDef + BASE_DAMAGE
            ? defenderAtk - attackerDef
            : BASE_DAMAGE;
        uint defenderHPLoss = (attackerAtk * INITIATIVE_BONUS) / ONE >
            defenderDef + BASE_DAMAGE
            ? (attackerAtk * INITIATIVE_BONUS) / ONE - defenderDef
            : BASE_DAMAGE;
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
        uint finalDamage = damage > totalDef ? damage - totalDef : BASE_DAMAGE;
        return finalDamage;
    }

    // harvest reusult per work unit
    // if low resource compare to demand, will reduce harvest and harvest per share
    // if supply higher than 2 x totalHarvastPoint will get full harvest.
    // otherwise will get harvest per share pernalty
    function harvestPerShare(
        uint supply,
        uint totalHarvastPoint
    ) public pure returns (uint) {
        if (supply > totalHarvastPoint * 2) {
            return totalHarvastPoint;
        }
        Math.log2(totalHarvastPoint);
        return (supply * totalHarvastPoint) / (totalHarvastPoint * 2);
    }

    // calculate buildinmg stat in sqrt scale
    function resource2Stat(
        uint progress,
        uint base,
        uint multiplier
    ) public pure returns (uint) {
        return (Math.sqrt((base + progress) / ONE) * multiplier);
    }

    function probHit(uint prob, uint randomness) public pure returns (bool) {
        return randomness % 100 < prob;
    }
}
