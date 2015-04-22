while(true) {
	if(keystroke) { // keystroke = R27
		if(left) direction = left; // direction = R6
		if(right) direction = right; // left = 0
		if(up) direction = up;		 // right = 1
		if(down) direction = down;	 // up = 2, down = 4
	}
	bool allowed_move = wall_check(direction, position); // allowed_move = R7
	if(!allowed_move) branch_to_keystroke; // B NEQ KEYSTROKE
	draw_sprite;
	// Check for interactions with other sprites
	// update score/health as necessary

}
// XCRD: 0:319 (0b100111111)
// YCRD: 0:239 (0b11101111)
// Memory structure:
// 0000000011111111000000001111111100000000111111110000000011111111
// 0000000011111111000000001111111100000000111111110000000011111111
// 0000000000000000000000000000000000000000000000000000000000000000
// 0000000000000000000000000000000000000000000000000000000000000000
// 1111111111110000000000001111111111110000000000001111111111110000
// 1111111111110000000000001111111111110000000000001111111111110000
// etc. etc. need to calculate which byte to load from memory
// x position: 0-7 is byte 0, 8-15 is byte 1, etc. etc.
// y position: add 40 bytes to index based on y-coordinate
// shift it right arithmetic by 3 bits to calculate x-base, then
// add 40 looped through based on y number
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
