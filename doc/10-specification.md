# lib.scad.clamps specification

## Purpose

The library provides reusable parametric clamp geometry without embedding a
consumer's mounting or product-specific decisions.

## Tube-clamp contract

The base tube clamp:

- represents a compact open snap-fit tube clamp;
- keeps the compact base mounting-neutral;
- distinguishes functional/visual bore diameter from optional tension bore;
- preserves configured wall thickness when tension geometry is selected;
- keeps the nominal tube/ring datum independent of Boolean overlap;
- exposes reusable derived dimensions through public APIs;
- keeps surface resolution out of the public geometry contract.

## Language implementations

OpenSCAD is the primary reusable-library direction and uses an object-based API.
PythonSCAD keeps an equivalent design implementation using native Python OOP.

Equivalent behavior is required where both implementations exist; identical API
syntax is not.

## Boundaries

The library does not own consumer mounting plates, product-specific placement,
repository tooling behavior, or a requirement that every future component have
both OpenSCAD and PythonSCAD implementations.
