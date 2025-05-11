shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D noise;

uniform vec2 center = vec2(.5, .5);
uniform vec2 iResolution = vec2(1280, 760);
uniform float angleFactor = 2.;
uniform float effectRadius = .5;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    float effectAngle = angleFactor * PI;


    vec2 uv = SCREEN_UV.xy - center;
    float len = length(uv * vec2(iResolution.x / iResolution.y, 1.));
    float angle = atan(uv.y, uv.x) + effectAngle * smoothstep(effectRadius, 0., len);
    float radius = length(uv);

    COLOR = texture(SCREEN_TEXTURE, vec2(radius * cos(angle), radius * sin(angle)) + center);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
