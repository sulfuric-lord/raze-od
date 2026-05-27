shader_type canvas_item;

uniform vec4 color_main : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 color_secondary : source_color = vec4(0.0, 0.0, 1.0, 1.0);

uniform float white_threshold = 0.25;
uniform float gray_threshold = 0.4;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // расстояние до белого
    float dist_to_white = distance(tex.rgb, vec3(1.0));

    // расстояние до серого (~0.5)
    float dist_to_gray = distance(tex.rgb, vec3(0.5));

    if (dist_to_white < white_threshold) {
        COLOR = vec4(color_main.rgb, tex.a);
    }
    else if (dist_to_gray < gray_threshold) {
        COLOR = vec4(color_secondary.rgb, tex.a);
    }
    else {
        COLOR = tex;
    }
}