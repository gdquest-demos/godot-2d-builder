class_name Recipes
extends Reference

const Fuels := {Lumber = 50.0, Coal = 100.0, Branches = 10.0}

const Smelting := {
	Ingot = {inputs = {"Ore": 1}, amount = 1, time = 5.0},
	Coal = {inputs = {"Lumber": 1}, amount = 1, time = 5.0}
}

const Crafting := {
	Pickaxe = {inputs = {"Branches": 2, "Ingot": 3}, amount = 1, time = 1.0},
	Axe = {inputs = {"Branches": 2, "Ingot": 3}, amount = 1, time = 1.0},
	Branches = {inputs = {"Lumber": 1, "Axe": 0}, amount = 5, time = 1.0}
}
