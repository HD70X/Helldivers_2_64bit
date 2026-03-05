# AGENTS.md

## Project Overview

This project is a fan-made 2D pixel shooter inspired by **Helldivers**.

The goal is to recreate the cooperative combat feel of Helldivers in a **2D side-scrolling format similar to Metal Slug**, using the **Godot Engine**.

The project focuses on:

- Co-op multiplayer
- Modular gameplay systems
- Expandable weapons and enemies
- Simple but satisfying combat loop

This project is currently in an early prototype stage.

---

## Engine

Godot Engine (GDScript)

---

## Repository Structure

Script/Core  
Shared systems such as event systems or utilities.

Script/GameData  
Pure data structures such as player stats, items, etc.

Script/GamePlay  
Gameplay logic such as player behavior, weapons, combat, and AI.

Script/UI  
User interface related scripts.

Scene  
Godot scenes.

Art  
Sprites and visual assets.

Resources  
Reusable assets and configuration resources.

---

## Coding Guidelines

- Use **GDScript**.
- Prefer **modular scripts** over large monolithic files.
- Avoid putting gameplay logic directly inside scenes.
- Keep systems loosely coupled.

Example modular systems:

- movement
- shooting
- damage
- AI
- weapons

---

## Gameplay Architecture Philosophy

Gameplay systems should be modular.

Example structure:

Player
- movement
- weapon controller
- health

Weapon
- firing logic
- cooldown / reload
- projectile spawn

Enemy
- simple AI
- health
- attack behavior

---

## Multiplayer Considerations

Future multiplayer implementation should follow a simple authority model:

Player  
Authority: owning client

Enemies  
Authority: host

Projectiles  
Authority: shooter

Avoid tightly coupling gameplay logic with networking.

Networking should be layered on top of gameplay systems when possible.

---

## When Adding Features

Prefer:

- creating new scripts
- keeping files small
- clear responsibilities per script

Avoid:

- large scripts exceeding ~400 lines
- mixing UI and gameplay logic
