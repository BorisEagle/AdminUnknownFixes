#!/usr/bin/env python3
"""Analyze simple Graphviz DOT files produced by tools/analyze-dump.py.

This is intentionally lightweight and does not need pydot/networkx. It extracts
quoted directed edges like:

    "source" -> "target";
    "source" -> "target" [label="..."];

and reports graph size, top in/out degree nodes, weak components, and optional
focus-neighborhood exports.
"""

from __future__ import annotations

import argparse
import csv
import re
from collections import Counter, defaultdict, deque
from pathlib import Path
from typing import Iterable

EDGE_RE = re.compile(r'^\s*"(?P<src>(?:[^"\\]|\\.)*)"\s*->\s*"(?P<dst>(?:[^"\\]|\\.)*)"')
NODE_RE = re.compile(r'^\s*"(?P<node>(?:[^"\\]|\\.)*)"\s*(?:\[.*\])?;\s*$')


def unescape_dot(value: str) -> str:
    return value.replace(r'\"', '"').replace(r'\\', '\\')


def parse_dot(path: Path):
    nodes: set[str] = set()
    edges: list[tuple[str, str]] = []

    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        m = EDGE_RE.match(line)
        if m:
            src = unescape_dot(m.group("src"))
            dst = unescape_dot(m.group("dst"))
            nodes.add(src)
            nodes.add(dst)
            edges.append((src, dst))
            continue

        m = NODE_RE.match(line)
        if m and "->" not in line:
            nodes.add(unescape_dot(m.group("node")))

    return nodes, edges


def weak_components(nodes: set[str], edges: Iterable[tuple[str, str]]):
    adj: dict[str, set[str]] = defaultdict(set)
    for a, b in edges:
        adj[a].add(b)
        adj[b].add(a)

    seen: set[str] = set()
    comps: list[list[str]] = []

    for node in nodes:
        if node in seen:
            continue
        q = deque([node])
        seen.add(node)
        comp = []
        while q:
            cur = q.popleft()
            comp.append(cur)
            for nxt in adj.get(cur, ()):  # isolated nodes are fine
                if nxt not in seen:
                    seen.add(nxt)
                    q.append(nxt)
        comps.append(comp)

    comps.sort(key=len, reverse=True)
    return comps


def neighborhood(edges: list[tuple[str, str]], focus: str, depth: int):
    forward: dict[str, set[str]] = defaultdict(set)
    backward: dict[str, set[str]] = defaultdict(set)
    for a, b in edges:
        forward[a].add(b)
        backward[b].add(a)

    selected = {focus}
    frontier = {focus}
    for _ in range(depth):
        nxt = set()
        for node in frontier:
            nxt.update(forward.get(node, ()))
            nxt.update(backward.get(node, ()))
        nxt -= selected
        selected |= nxt
        frontier = nxt
        if not frontier:
            break

    selected_edges = [(a, b) for a, b in edges if a in selected and b in selected]
    return selected, selected_edges


def write_dot(path: Path, nodes: set[str], edges: list[tuple[str, str]], title: str):
    with path.open("w", encoding="utf-8", newline="") as f:
        f.write(f'digraph "{title}" {{\n')
        f.write('  graph [rankdir=LR];\n')
        f.write('  node [shape=box];\n')
        for node in sorted(nodes):
            escaped = node.replace('\\', '\\\\').replace('"', '\\"')
            f.write(f'  "{escaped}";\n')
        for a, b in edges:
            ea = a.replace('\\', '\\\\').replace('"', '\\"')
            eb = b.replace('\\', '\\\\').replace('"', '\\"')
            f.write(f'  "{ea}" -> "{eb}";\n')
        f.write('}\n')


def write_counter_csv(path: Path, rows: list[tuple[str, int]], header: tuple[str, str]):
    with path.open("w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(rows)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("dot", type=Path, help="DOT file to analyze")
    ap.add_argument("--out", type=Path, default=Path("dot-analysis"), help="Output directory")
    ap.add_argument("--top", type=int, default=50, help="Top degree rows to export")
    ap.add_argument("--focus", action="append", default=[], help="Node name to export a local neighborhood for")
    ap.add_argument("--depth", type=int, default=2, help="Neighborhood depth for --focus")
    args = ap.parse_args()

    nodes, edges = parse_dot(args.dot)
    args.out.mkdir(parents=True, exist_ok=True)

    indeg = Counter()
    outdeg = Counter()
    for a, b in edges:
        outdeg[a] += 1
        indeg[b] += 1

    comps = weak_components(nodes, edges)

    summary = {
        "file": str(args.dot),
        "nodes": len(nodes),
        "edges": len(edges),
        "weak_components": len(comps),
        "largest_component_nodes": len(comps[0]) if comps else 0,
        "isolated_nodes": sum(1 for c in comps if len(c) == 1),
    }

    summary_path = args.out / f"{args.dot.stem}-summary.txt"
    with summary_path.open("w", encoding="utf-8") as f:
        for k, v in summary.items():
            f.write(f"{k}: {v}\n")
        f.write("\nTop out-degree:\n")
        for node, count in outdeg.most_common(args.top):
            f.write(f"{count}\t{node}\n")
        f.write("\nTop in-degree:\n")
        for node, count in indeg.most_common(args.top):
            f.write(f"{count}\t{node}\n")
        f.write("\nLargest components:\n")
        for i, comp in enumerate(comps[:20], 1):
            f.write(f"{i}\t{len(comp)}\n")

    write_counter_csv(
        args.out / f"{args.dot.stem}-top-out-degree.csv",
        outdeg.most_common(args.top),
        ("node", "out_degree"),
    )
    write_counter_csv(
        args.out / f"{args.dot.stem}-top-in-degree.csv",
        indeg.most_common(args.top),
        ("node", "in_degree"),
    )

    for focus in args.focus:
        selected_nodes, selected_edges = neighborhood(edges, focus, args.depth)
        safe = re.sub(r"[^A-Za-z0-9_.-]+", "_", focus).strip("_") or "focus"
        write_dot(
            args.out / f"{args.dot.stem}-around-{safe}-d{args.depth}.dot",
            selected_nodes,
            selected_edges,
            f"{args.dot.stem} around {focus}",
        )

    print(f"Analyzed {args.dot}")
    print(f"nodes={len(nodes)} edges={len(edges)} components={len(comps)}")
    print(f"Reports written to {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
