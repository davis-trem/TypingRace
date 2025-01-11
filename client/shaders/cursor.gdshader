shader_type canvas_item;

const float blink_speed = 2.0; // Speed of the blinking (Hz)
uniform bool should_blink = true;
uniform bool mistake_made = false;

void fragment() {
	if (mistake_made) {
		COLOR = vec4(0.85, 0.0, 0.0, 1.0);
	}
	
	// is TIME even or odd
	if (should_blink) {
		float blink_state = mod(TIME * blink_speed, 2.0) < 1.0 ? 1.0 : 0.0;
		COLOR.a = blink_state;
	}
}
