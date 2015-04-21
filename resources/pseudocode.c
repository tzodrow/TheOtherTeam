while(true) {
	if(keystroke) {
		if(left) direction = left;
		if(right) direction = right;
		if(up) direction = up;
		if(down) direction = down;
	}
	bool allowed_move = wall_check(direction, position);
	if(!allowed_move) branch_to_keystroke;
	draw_sprite;
	// Check for interactions with other sprites
	// update score/health as necessary
	
}

bool wall_check(direction, position) {
	if(direction == left) {
		if(left_position - 1 == wall)
			result = false;
		else {
			sprite_position_x -= 1;
			result = true;
		}
	}
	else if(direction == right) {
		if(right_position + 1 == wall) 
			result = false;
		else {
			sprite_position_x += 1;
			result = true;
		}
	}
	else if(direction == up) {
		if(top_position + 1 == wall) 
			result = false;
		else {
			sprite_position_y += 1;
			result = true;
		}
	}
	else if(direction == down) {
		if(top_position - 1 == wall) 
			result = false;
		else {
			sprite_position_y -= 1;
			draw_sprite;
		}
	}
}
