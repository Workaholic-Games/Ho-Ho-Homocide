shader_type canvas_item;

// A value between 0.0 (empty) and 1.0 (full)
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 bar_color : source_color = vec4(0.2, 0.7, 0.3, 1.0); // Default Green
uniform vec4 bg_color : source_color = vec4(0.1, 0.1, 0.1, 0.5);  // Transparent Black

void fragment() {
    // UV.x goes from 0.0 (left) to 1.0 (right)
    if (UV.x < progress) {
        COLOR = bar_color;
    } else {
        COLOR = bg_color;
    }
}
