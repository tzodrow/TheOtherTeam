while(true) {
	if(keystroke) {
		if(left) direction = left;
		if(right) direction = right;
		if(up) direction = up;
		if(down) direction = down;
	}
	// check if running into wall
	if(direction == left) {
		if(left_position - 1 == wall) {// memory read
			// branch to next cycle, poll for keystroke
		}
		else {
			sprite_position_x -= 1;
			draw_sprite;
		}
	}
	else if(direction == right) {
		if(right_position + 1 == wall) {
			// branch to next cycle, poll for keystroke
		}
		else {
			sprite_position_x += 1;
			draw_sprite;
		}
	}
	else if(direction == up) {
		if(top_position + 1 == wall) {
			// branch to next cycle, poll for keystroke
		}
		else {
			sprite_position_y += 1;
			draw_sprite;
		}
	}
	else if(direction == down) {
		if(top_position - 1 == wall) {
			// branch to next cycle, poll for keystroke
		}
		else {
			sprite_position_y -= 1;
			draw_sprite;
		}
	}

}
