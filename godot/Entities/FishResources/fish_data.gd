class_name FishData
extends Resource

## How likely it is that the fish fights against the player. Should be 1-100, inclusive. Higher values result in more frequent fighting.
@export var erraticism: float

## In seconds, how often the fish check to see if it will fight against the player.
@export var fight_check_frequency: float = .5

## How strongly the fish fights against the player in every instance.
@export var fight_power: float

## How much the fish weighs. Higher values result in a more difficult(slower) reeling experience
@export var mass: float = 1

## The minimum angle by which a fish's fight direction will be rotated.[br]
## Initial direction is the vector towards the player, which is then rotated away from the player.
@export var min_fight_angle: float

## The maximum angle by which a fish's fight direction will be rotated.[br]
## Initial direction is the vector towards the player, which is then rotated away from the player.
@export var max_fight_angle: float
