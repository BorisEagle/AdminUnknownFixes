#!/usr/bin/env python3
"""Analyze Factorio --dump-data output for large modpack compatibility testing.

Input:  data-raw-dump.json from Factorio script-output
Output: reports with technologies, recipes, missing producers, and graph source files.

This is intentionally conservative: it does not try to prove full progression yet.
It finds obvious prototype graph problems that are worth checking in gameplay.
"""

from __future__ import annotations

import argparse
import csv
import json
from collections import defaultdict
from pathlib import Path
from typing import Any, Iterable


ITEM_LIKE_TYPES = {
    "item",
    "ammo",
    "armor",
    "blueprint",
    "blueprint-book",
    "capsule",
    "copy-paste-tool",
    "deconstruction-item",
    "gun",
    "item-with-entity-data",
    "item-with-inventory",
    "item-with-label",
    "item-with-tags",
    "module",
    "rail-planner",
    "repair-tool",
    "selection-tool",
    "space-platform-starter-pack",
    "spidertron-remote",
    "tool",
    "upgrade-item",
}


INTRINSIC_SOURCES = {
    # Environment / map generation / vanilla conceptual sources. This list is small on purpose.
    "coal",
    "copper-ore",
    "crude-oil",
    "iron-ore",
    "stone",
    "uranium-ore",
    "water",
    "wood",
}


SINK_RECIPE_SUFFIXES = (
    "-pyvoid",
    "-void",
    "-sink",
    "-recycling",
)

SINK_RECIPE_NAMES = {
    "used-nuclear-fuel",
}


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def collect_item_like_names(data: dict[str, Any]) -> tuple[set[str], dict[str, str]]:
    """Return all names that can legally appear as item products/ingredients.

    Factorio dump groups item subclasses under their prototype type, not only under
    data.raw.item. Recipes can use modules, tools/science packs, ammo, capsules,
    armor, guns, rail planners, etc. Counting only data.raw.item creates thousands
    of fake errors. Yes, of course the obvious field name was not enough.
    """
    names: set[str] = set()
    name_to_type: dict[str, str] = {}
    for type_name in ITEM_LIKE_TYPES:
        prototypes = data.get(type_name)
        if not isinstance(prototypes, dict):
            continue
        for name in prototypes.keys():
            names.add(name)
            name_to_type[name] = type_name
    return names, name_to_type


def is_sink_recipe(recipe_name: str) -> bool:
    return recipe_name in SINK_RECIPE_NAMES or recipe_name.endswith(SINK_RECIPE_SUFFIXES)


def recipe_variants(recipe: dict[str, Any]) -> Iterable[dict[str, Any]]:
    yielded = False
    if isinstance(recipe.get("normal"), dict):
        yielded = True
        yield recipe["normal"]
    if isinstance(recipe.get("expensive"), dict):
        yielded = True
        yield recipe["expensive"]
    if not yielded:
        yield recipe


def entry_name(entry: Any) -> str | None:
    if isinstance(entry, dict):
        return entry.get("name") or entry.get("1")
    if isinstance(entry, list) and entry:
        return entry[0]
    return None


def iter_recipe_entries(recipe: dict[str, Any], key: str) -> Iterable[Any]:
    for variant in recipe_variants(recipe):
        value = variant.get(key)
        if isinstance(value, list):
            yield from value
        elif isinstance(value, dict):
            yield value


def recipe_results(recipe_name: str, recipe: dict[str, Any]) -> list[str]:
    out: list[str] = []
    for variant in recipe_variants(recipe):
        if isinstance(variant.get("results"), list):
            for entry in variant["results"]:
                name = entry_name(entry)
                if name:
                    out.append(name)
        elif isinstance(variant.get("result"), str):
            out.append(variant["result"])
        elif isinstance(recipe.get("main_product"), str):
            out.append(recipe["main_product"])
    return sorted(set(out))


def recipe_ingredients(recipe: dict[str, Any]) -> list[str]:
    out: list[str] = []
    for entry in iter_recipe_entries(recipe, "ingredients"):
        name = entry_name(entry)
        if name:
            out.append(name)
    return sorted(set(out))


def tech_unlocks(tech: dict[str, Any]) -> list[str]:
    out: list[str] = []
    for effect in tech.get("effects") or []:
        if isinstance(effect, dict) and effect.get("type") == "unlock-recipe" and effect.get("recipe"):
            out.append(effect["recipe"])
    return sorted(set(out))


def write_csv(path: Path, rows: list[dict[str, Any]], fields: list[str]) -> None:
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)


def dot_quote(value: str) -> str:
    return '"' + value.replace('\\', '\\\\').replace('"', '\\"') + '"'


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("dump", type=Path, help="Path to data-raw-dump.json")
    parser.add_argument("--out", type=Path, default=Path("analysis-output"), help="Output directory")
    args = parser.parse_args()

    data = load_json(args.dump)
    out = args.out
    out.mkdir(parents=True, exist_ok=True)

    item_like, item_type_by_name = collect_item_like_names(data)
    fluids: set[str] = set(data.get("fluid", {}).keys())
    recipes: dict[str, dict[str, Any]] = data.get("recipe", {})
    technologies: dict[str, dict[str, Any]] = data.get("technology", {})
    resources: dict[str, dict[str, Any]] = data.get("resource", {})

    valid_products = item_like | fluids

    producer_by_product: dict[str, set[str]] = defaultdict(set)
    for resource_name, resource in resources.items():
        minable = resource.get("minable") or {}
        for entry_key in ("results", "result"):
            value = minable.get(entry_key)
            if isinstance(value, str):
                producer_by_product[value].add(f"resource:{resource_name}")
            elif isinstance(value, list):
                for entry in value:
                    name = entry_name(entry)
                    if name:
                        producer_by_product[name].add(f"resource:{resource_name}")

    recipe_rows: list[dict[str, Any]] = []
    ingredient_edges: list[tuple[str, str]] = []
    product_edges: list[tuple[str, str]] = []
    bad_recipe_refs: list[dict[str, Any]] = []
    consumer_by_ingredient: dict[str, set[str]] = defaultdict(set)

    for recipe_name, recipe in sorted(recipes.items()):
        ingredients = recipe_ingredients(recipe)
        products = recipe_results(recipe_name, recipe)
        category = recipe.get("category", "crafting")
        enabled = recipe.get("enabled", "")
        recipe_rows.append({
            "recipe": recipe_name,
            "category": category,
            "enabled": enabled,
            "ingredients": ";".join(ingredients),
            "products": ";".join(products),
        })
        for product in products:
            producer_by_product[product].add(f"recipe:{recipe_name}")
            product_edges.append((recipe_name, product))
            if product not in valid_products:
                bad_recipe_refs.append({"recipe": recipe_name, "field": "product", "name": product})
        for ingredient in ingredients:
            consumer_by_ingredient[ingredient].add(recipe_name)
            ingredient_edges.append((ingredient, recipe_name))
            if ingredient not in valid_products:
                bad_recipe_refs.append({"recipe": recipe_name, "field": "ingredient", "name": ingredient})

    tech_rows: list[dict[str, Any]] = []
    bad_tech_refs: list[dict[str, Any]] = []
    tech_edges: list[tuple[str, str]] = []

    for tech_name, tech in sorted(technologies.items()):
        prereqs = sorted(tech.get("prerequisites") or [])
        unlocks = tech_unlocks(tech)
        tech_rows.append({
            "technology": tech_name,
            "prerequisites": ";".join(prereqs),
            "unlocks": ";".join(unlocks),
        })
        for prereq in prereqs:
            tech_edges.append((prereq, tech_name))
            if prereq not in technologies:
                bad_tech_refs.append({"technology": tech_name, "field": "prerequisite", "name": prereq})
        for recipe in unlocks:
            if recipe not in recipes:
                bad_tech_refs.append({"technology": tech_name, "field": "unlock", "name": recipe})

    no_known_producer: list[dict[str, Any]] = []
    no_known_producer_sink_only: list[dict[str, Any]] = []
    for ingredient in sorted({edge[0] for edge in ingredient_edges}):
        if ingredient in producer_by_product or ingredient in INTRINSIC_SOURCES:
            continue
        consumers = sorted(consumer_by_ingredient.get(ingredient, set()))
        row = {
            "item_or_fluid": ingredient,
            "prototype_type": "fluid" if ingredient in fluids else item_type_by_name.get(ingredient, "unknown"),
            "consumer_count": len(consumers),
            "consuming_recipes": ";".join(consumers[:25]),
        }
        if consumers and all(is_sink_recipe(recipe_name) for recipe_name in consumers):
            no_known_producer_sink_only.append(row)
        else:
            no_known_producer.append(row)

    no_known_producer.sort(key=lambda row: (-int(row["consumer_count"]), row["item_or_fluid"]))
    no_known_producer_sink_only.sort(key=lambda row: (-int(row["consumer_count"]), row["item_or_fluid"]))

    write_csv(out / "recipes.csv", recipe_rows, ["recipe", "category", "enabled", "ingredients", "products"])
    write_csv(out / "technologies.csv", tech_rows, ["technology", "prerequisites", "unlocks"])
    write_csv(out / "bad-recipe-references.csv", bad_recipe_refs, ["recipe", "field", "name"])
    write_csv(out / "bad-technology-references.csv", bad_tech_refs, ["technology", "field", "name"])
    write_csv(out / "items-without-known-producer.csv", no_known_producer, ["item_or_fluid", "prototype_type", "consumer_count", "consuming_recipes"])
    write_csv(out / "sink-only-items-without-known-producer.csv", no_known_producer_sink_only, ["item_or_fluid", "prototype_type", "consumer_count", "consuming_recipes"])

    with (out / "research-tree.dot").open("w", encoding="utf-8") as f:
        f.write("digraph research_tree {\n")
        f.write("  rankdir=LR;\n")
        for src, dst in tech_edges:
            f.write(f"  {dot_quote(src)} -> {dot_quote(dst)};\n")
        f.write("}\n")

    with (out / "production-graph.dot").open("w", encoding="utf-8") as f:
        f.write("digraph production_graph {\n")
        f.write("  rankdir=LR;\n")
        for item, recipe in ingredient_edges:
            f.write(f"  {dot_quote(item)} -> {dot_quote('recipe:' + recipe)};\n")
        for recipe, product in product_edges:
            f.write(f"  {dot_quote('recipe:' + recipe)} -> {dot_quote(product)};\n")
        f.write("}\n")

    summary = {
        "item_like_prototypes": len(item_like),
        "fluids": len(fluids),
        "recipes": len(recipes),
        "technologies": len(technologies),
        "resources": len(resources),
        "bad_recipe_references": len(bad_recipe_refs),
        "bad_technology_references": len(bad_tech_refs),
        "blocking_items_or_fluids_without_known_producer": len(no_known_producer),
        "sink_only_items_or_fluids_without_known_producer": len(no_known_producer_sink_only),
    }
    (out / "summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")

    print(json.dumps(summary, indent=2))
    print(f"Reports written to {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
