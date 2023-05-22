// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./StuffLib.sol";
import "./BonusLib.sol";
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
    uint public round;
    IIslander[] islanders;
    mapping(uint => IslanderInfo) islanderInfos;
    World world;

    constructor(IIslander[] memory _islanders, uint _randomness) {
        randomness = _randomness;
        round = 0;
        islanders = _islanders;

        // Initialize world
        generateWorld();

        // Initialize islanders
        for (uint i = 0; i < _islanders.length; ++i) {
            islanderInfos[i].idx = uint8(i);
            islanderInfos[i].hp = Constants.INITIAL_HP;
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

    function generateWorld() internal {
        world.wood.supply = uint32(Constants.TREE_CAPACITY_K_T);
        world.fruit.supply = uint32(Constants.TREE_CAPACITY_FROM_FRUIT_K_F);
        world.animal.supply = uint32(
            (Constants.ANIMAL_REPRODUCTION_RATE_BETA *
                Constants.TREE_CAPACITY_FROM_FRUIT_K_F) / Constants.ONE
        );
        world.rock.supply = uint32(Constants.ROCK_CAPACITY_K_R);
        world.fish.supply = uint32(Constants.FISH_CAPACITY_K_V);
        world.pearl.supply = uint32(Constants.PEARL_CAPACITY_K_P);
    }

    function harvestPhase() internal {
        Resources[] memory harvestPlans = new Resources[](islanders.length);
        Resources memory totalHarvestPoint = Resources(0, 0, 0, 0, 0, 0);

        // Get harvest plan for each islander
        for (uint i = 0; i < islanders.length; ++i) {
            // Skip dead islanders
            if (islanderInfos[i].hp == 0) continue;

            try islanders[i].planHarvest(world, islanderInfos[i]) returns (
                Resources memory plan
            ) {
                // Save islander latest harvest plan
                islanderInfos[i].harvestPlan.push(plan);
                // Normalize harvest plan with bonus
                harvestPlans[i] = SystemLib.normalizeWithBonus(
                    plan,
                    islanderInfos[i].buildings.harvest,
                    world.buildings.harvest
                );
                // Sum total harvest point
                totalHarvestPoint.rock += harvestPlans[i].rock;
                totalHarvestPoint.wood += harvestPlans[i].wood;
                totalHarvestPoint.fruit += harvestPlans[i].fruit;
                totalHarvestPoint.animal += harvestPlans[i].animal;
                totalHarvestPoint.fish += harvestPlans[i].fish;
                totalHarvestPoint.pearl += harvestPlans[i].pearl;
            } catch {}
        }

        // Calculate harvest per share for each resource
        // and update world supply and previous harvest stat
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

        // Update islander resources
        for (uint i = 0; i < islanders.length; ++i) {
            Resources memory harvestPlan = harvestPlans[i];
            IslanderInfo storage islander = islanderInfos[i];

            // Skip dead islanders
            if (islander.hp == 0) continue;

            islander.pearl += harvestPlan.pearl * pearlHarvestPerShare;
            islander.resources.rock += harvestPlan.rock * rockHarvestPerShare;
            islander.resources.wood += harvestPlan.wood * woodHarvestPerShare;
            islander.resources.food += uint32(
                ((Constants.FOOD_UNIT_PER_FRUIT_PCT *
                    harvestPlan.fruit *
                    fruitHarvestPerShare) +
                    (Constants.FOOD_UNIT_PER_MEAT_PCT *
                        harvestPlan.animal *
                        animalHarvestPerShare) +
                    (Constants.FOOD_UNIT_PER_FISH_PCT *
                        harvestPlan.fish *
                        fishHarvestPerShare)) / Constants.ONE
            );
        }
    }

    function communityBuildPhase() internal {
        // Get community building plan for each islander
        for (uint i = 0; i < islanders.length; ++i) {
            try
                islanders[i].planCommunityBuild(world, islanderInfos[i])
            returns (Buildings memory plan) {
                IslanderInfo storage islander = islanderInfos[i];

                // Skip dead islanders
                if (islander.hp == 0) continue;

                Buildings storage worldBuildings = world.buildings;

                // Save islander latest community building plan
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

    function personalBuildPhase() internal {
        // Get personal building plan for each islander
        for (uint i = 0; i < islanders.length; ++i) {
            try
                islanders[i].planPersonalBuild(world, islanderInfos[i])
            returns (Buildings memory plan) {
                IslanderInfo storage islander = islanderInfos[i];

                // Skip dead islanders
                if (islander.hp == 0) continue;

                // Save islander latest personal building plan
                islander.personalBuildingPlan.push(plan);

                // Upgrade rock harvest using wood
                if (islander.resources.wood >= plan.harvest.rock) {
                    islander.buildings.harvest.rock += plan.harvest.rock;
                    islander.resources.rock -= plan.harvest.rock;
                }

                // Upgrade wood harvest using wood
                if (islander.resources.wood >= plan.harvest.wood) {
                    islander.buildings.harvest.wood += plan.harvest.wood;
                    islander.resources.wood -= plan.harvest.wood;
                }

                // Upgrade food harvest using wood
                if (islander.resources.wood >= plan.harvest.food) {
                    islander.buildings.harvest.food += plan.harvest.food;
                    islander.resources.wood -= plan.harvest.food;
                }

                // Upgrade survival using wood
                if (islander.resources.wood >= plan.survival) {
                    islander.buildings.survival += plan.survival;
                    islander.resources.wood -= plan.survival;
                }

                // Upgrade protection using wood
                if (islander.resources.wood >= plan.protection) {
                    islander.buildings.protection += plan.protection;
                    islander.resources.wood -= plan.protection;
                }

                // Upgrade statue using rock
                if (islander.resources.rock >= plan.statue) {
                    islander.buildings.statue += plan.statue;
                    islander.resources.rock -= plan.statue;
                }

                // Upgrade atk using rock
                if (islander.resources.rock >= plan.atk) {
                    islander.buildings.atk += plan.atk;
                    islander.resources.rock -= plan.atk;
                }

                // Upgrade def using rock
                if (islander.resources.rock >= plan.def) {
                    islander.buildings.def += plan.def;
                    islander.resources.rock -= plan.def;
                }
            } catch {}
        }
    }

    function visitPhase() internal {
        int32[] memory healthDiffs = new int32[](islanders.length);
        for (uint i = 0; i < islanders.length; ++i) {
            for (uint j = 0; j < islanders.length; ++j) {
                if (i == j) continue;

                IslanderInfo memory islander_self = islanderInfos[i];
                IslanderInfo memory islander_other = islanderInfos[j];

                // Skip dead islanders
                if (islander_self.hp == 0 || islander_other.hp == 0) continue;

                (
                    uint32 damageDealtIfAttack,
                    uint32 damageTakenIfAttack
                ) = SystemLib.battleDamage(
                        BonusLib.individualAttackBonus(
                            islander_self.buildings.atk
                        ),
                        BonusLib.individualDefenseBonus(
                            islander_self.buildings.def
                        ),
                        BonusLib.individualAttackBonus(
                            islander_other.buildings.atk
                        ),
                        BonusLib.individualDefenseBonus(
                            islander_other.buildings.def
                        )
                    );

                try
                    islanders[i].planVisit(
                        world,
                        islander_self,
                        islander_other,
                        damageDealtIfAttack,
                        damageTakenIfAttack
                    )
                returns (Action action) {
                    // TODO: handle other type of action
                    if (action == Action.Attack) {
                        // Attack
                        // Add damage to self and other islander
                        healthDiffs[i] -= int32(damageTakenIfAttack);
                        healthDiffs[j] -= int32(damageDealtIfAttack);
                    }
                } catch {}
            }
        }

        for (uint i = 0; i < islanders.length; ++i) {
            IslanderInfo storage islander = islanderInfos[i];

            // Skip dead islanders
            if (islander.hp == 0) continue;

            int32 diff = healthDiffs[i];
            if (diff > 0) {
                // Heal
                islander.hp += uint32(diff);
            } else if (diff < 0) {
                uint32 damage = uint32(diff);
                // Damage
                if (damage >= islander.hp) {
                    // Dead
                    islander.hp = 0;
                } else {
                    // Survive
                    islander.hp -= damage;
                }
            }
        }
    }

    function worldUpdate() internal {
        (bool isDisasterHit, uint32 disasterDamage) = SystemLib.isDisasterHit(
            round,
            nextRandomness()
        );

        // Eat food and take disaster
        for (uint i = 0; i < islanders.length; ++i) {
            IslanderInfo storage islander = islanderInfos[i];

            // Skip dead islanders
            if (islander.hp == 0) continue;

            // Eat food
            {
                uint32 maxHp = Constants.INITIAL_HP +
                    BonusLib.individualSurvivalBonus(
                        islander.buildings.survival
                    ) +
                    BonusLib.communitySurvivalBonus(world.buildings.survival);

                // Eat 1 unit of food to prevent hp loss
                if (islander.resources.food == 0) {
                    // Lose HEALTH_PER_FOOD_UNIT hp if no food
                    islander.hp -= uint32(Constants.HEALTH_PER_FOOD_UNIT);
                } else {
                    islander.resources.food -= uint32(Constants.ONE);

                    // Eat some food proportional to max hp to recover hp
                    if (islander.resources.food > uint32(Constants.ONE)) {
                        uint32 foodAbleToEat = SystemLib.calculateFoodToEat(
                            maxHp
                        );
                        uint32 foodToEat = foodAbleToEat >
                            islander.resources.food
                            ? islander.resources.food
                            : foodAbleToEat;
                        islander.resources.food -= foodToEat;
                        islander.hp += uint32(
                            foodToEat * Constants.HEALTH_PER_FOOD_UNIT
                        );
                    }
                }
            }

            // Handle Disaster
            if (isDisasterHit) {
                if (disasterDamage >= islander.hp) {
                    // Dead
                    islander.hp = 0;
                } else {
                    // Survive
                    islander.hp -= disasterDamage;
                }
            }
        }

        uint deadPplAmt = 0;
        for (uint i = 0; i < islanders.length; ++i) {
            IslanderInfo storage islander = islanderInfos[i];
            if (islander.hp == 0) {
                deadPplAmt += 1;
            } else {
                // Increase day lived
                islander.dayLived += 1;
            }
        }

        if (deadPplAmt == islanders.length) {
            end();
            return;
        }

        // Update world and regen
        round += 1;
        {
            int32 woodRegen = SystemLib.calculateTreeRegen(
                world.wood.supply,
                world.fruit.supply
            );
            int32 fruitRegen = SystemLib.calculateFruitRegen(
                world.wood.supply,
                world.fruit.supply,
                world.animal.supply
            );
            int32 animalRegen = SystemLib.calculateAnimalRegen(
                world.fruit.supply,
                world.animal.supply
            );
            int32 fishRegen = SystemLib.calculateFishRegen(world.fish.supply);

            world.wood.supply += uint32(woodRegen);
            world.wood.prevRegen = uint32(woodRegen);
            world.fruit.supply += uint32(fruitRegen);
            world.fruit.prevRegen = uint32(fruitRegen);
            world.animal.supply += uint32(animalRegen);
            world.animal.prevRegen = uint32(animalRegen);
            world.fish.supply += uint32(fishRegen);
            world.fish.prevRegen = uint32(fishRegen);
        }
    }

    function end() internal {}
}
