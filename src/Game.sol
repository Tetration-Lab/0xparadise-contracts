// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./StuffLib.sol";
import "./SystemLib.sol";
import "./IIslander.sol";
import "./Constants.sol";

contract Game {
    event Dead(uint8 idx);
    event Attack(uint8 idx, uint8 targetIdx, uint damageAtk, uint damageDef);
    event Heal(uint8 idx, uint8 targetIdx, uint heal);
    event BuildCommu(uint8 idx, Buildings plan);
    event BuildPersonal(uint8 idx, Buildings plan);
    event Harvest(uint8 idx, Resources harvest);
    event Disaster(uint damage);
    event WorldUpdate(World world);

    uint256 public randomness;
    uint public rounds;
    IIslander[] islanders;
    mapping(uint => IslanderInfo) islanderInfos;
    World world;

    constructor(IIslander[] memory _islanders, uint _randomness) {
        randomness = _randomness;
        rounds = 0;
        islanders = _islanders;
        for (uint i = 0; i < islanders.length; ++i) {
            islanderInfos[i].idx = uint8(i);
            islanderInfos[i].hp = Constants.INITIAL_HP;
            islanderInfos[i].atk = Constants.INITIAL_ATK;
            islanderInfos[i].def = Constants.INITIAL_DEF;
        }
    }

    function step(uint nStep) public {
        for (uint i = 0; i < nStep; i++) {
            harvestPhase();
            communityBuildPhase();
            personalBuildPhase();
            visitPhase();
            worldUpdate();
        }
    }

    function nextRandomness() internal returns (uint) {
        randomness = uint(keccak256(abi.encode(randomness, world)));
        return randomness;
    }

    function harvestPhase() internal {
        Resources[] memory harvestPlans = new Resources[](islanders.length);
        Resources memory totalHarvestPoint = Resources(0, 0, 0, 0, 0, 0);
        for (uint i = 0; i < islanders.length; ++i) {
            try islanders[i].planHarvest(world, islanderInfos[i]) returns (
                Resources memory plan
            ) {
                islanderInfos[i].harvestPlan.push(plan);
                harvestPlans[i] = SystemLib.normalizeWithBonus(
                    plan,
                    islanderInfos[i].buildingLevel.harvest,
                    world.buildings.harvest
                );
                totalHarvestPoint.rock += harvestPlans[i].rock;
                totalHarvestPoint.wood += harvestPlans[i].wood;
                totalHarvestPoint.fruit += harvestPlans[i].fruit;
                totalHarvestPoint.animal += harvestPlans[i].animal;
                totalHarvestPoint.fish += harvestPlans[i].fish;
                totalHarvestPoint.pearl += harvestPlans[i].pearl;
            } catch {}
        }

        uint32 rockHarvestPerShare = SystemLib.harvestPerShare(
            world.rock.supply,
            totalHarvestPoint.rock
        );
        world.rock.prevHarvest = rockHarvestPerShare * totalHarvestPoint.rock;
        world.rock.supply -= world.rock.prevHarvest;

        uint32 woodHarvestPerShare = SystemLib.harvestPerShare(
            world.wood.supply,
            totalHarvestPoint.wood
        );
        world.wood.prevHarvest = woodHarvestPerShare * totalHarvestPoint.wood;
        world.wood.supply -= world.wood.prevHarvest;

        uint32 fruitHarvestPerShare = SystemLib.harvestPerShare(
            world.fruit.supply,
            totalHarvestPoint.fruit
        );
        world.fruit.prevHarvest =
            fruitHarvestPerShare *
            totalHarvestPoint.fruit;
        world.fruit.supply -= world.fruit.prevHarvest;

        uint32 animalHarvestPerShare = SystemLib.harvestPerShare(
            world.animal.supply,
            totalHarvestPoint.animal
        );
        world.animal.prevHarvest =
            animalHarvestPerShare *
            totalHarvestPoint.animal;
        world.animal.supply -= world.animal.prevHarvest;

        uint32 fishHarvestPerShare = SystemLib.harvestPerShare(
            world.fish.supply,
            totalHarvestPoint.fish
        );
        world.fish.prevHarvest = fishHarvestPerShare * totalHarvestPoint.fish;
        world.fish.supply -= world.fish.prevHarvest;

        uint32 pearlHarvestPerShare = SystemLib.harvestPerShare(
            world.pearl.supply,
            totalHarvestPoint.pearl
        );
        world.pearl.prevHarvest =
            pearlHarvestPerShare *
            totalHarvestPoint.pearl;
        world.pearl.supply -= world.pearl.prevHarvest;

        for (uint i = 0; i < islanders.length; ++i) {
            Resources memory harvestPlan = harvestPlans[i];
            IslanderInfo storage islander = islanderInfos[i];
            islander.pearl += harvestPlan.pearl * pearlHarvestPerShare;
            islander.resources.rock += harvestPlan.rock * rockHarvestPerShare;
            islander.resources.wood += harvestPlan.wood * woodHarvestPerShare;
            islander.resources.food +=
                harvestPlan.fruit *
                fruitHarvestPerShare +
                harvestPlan.animal *
                animalHarvestPerShare +
                harvestPlan.fish *
                fishHarvestPerShare;
        }
    }

    function communityBuildPhase() internal {
        for (uint i = 0; i < islanders.length; ++i) {
            try
                islanders[i].planCommunityBuild(world, islanderInfos[i])
            returns (Buildings memory plan) {
                IslanderInfo storage islander = islanderInfos[i];
                Buildings storage worldBuildings = world.buildings;

                islander.communityBuildingPlan.push(plan);

                // Upgrade rock harvest using wood
                if (islander.resources.wood >= plan.harvest.rock) {
                    worldBuildings.harvest.rock += plan.harvest.rock;
                    islander.resources.rock -= plan.harvest.rock;
                }

                // Upgrade wood harvest using wood
                if (islander.resources.wood >= plan.harvest.wood) {
                    worldBuildings.harvest.wood += plan.harvest.wood;
                    islander.resources.wood -= plan.harvest.wood;
                }

                // Upgrade food harvest using wood
                if (islander.resources.wood >= plan.harvest.food) {
                    worldBuildings.harvest.food += plan.harvest.food;
                    islander.resources.wood -= plan.harvest.food;
                }

                // Upgrade survival using wood
                if (islander.resources.wood >= plan.survival) {
                    worldBuildings.survival += plan.survival;
                    islander.resources.wood -= plan.survival;
                }

                // Upgrade protection using wood
                if (islander.resources.wood >= plan.protection) {
                    worldBuildings.protection += plan.protection;
                    islander.resources.wood -= plan.protection;
                }

                // Upgrade statue using rock
                if (islander.resources.rock >= plan.statue) {
                    worldBuildings.statue += plan.statue;
                    islander.resources.rock -= plan.statue;
                }

                // Upgrade atk using rock
                if (islander.resources.rock >= plan.atk) {
                    worldBuildings.atk += plan.atk;
                    islander.resources.rock -= plan.atk;
                }

                // Upgrade def using rock
                if (islander.resources.rock >= plan.def) {
                    worldBuildings.def += plan.def;
                    islander.resources.rock -= plan.def;
                }
            } catch {}
        }
    }

    function personalBuildPhase() internal {}

    function visitPhase() internal {}

    function worldUpdate() internal {}
}
