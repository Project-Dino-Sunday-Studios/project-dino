extends Node

enum PlayerState {
	TRAVERSE,
	AIM,
	FISH,
	ARRANGE_INVENTORY
}

var current_player_state: PlayerState
