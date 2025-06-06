RSRC                    VisualShader            �\q��S,                                            X      resource_local_to_scene    resource_name    noise_type    seed 
   frequency    offset    fractal_type    fractal_octaves    fractal_lacunarity    fractal_gain    fractal_weighted_strength    fractal_ping_pong_strength    cellular_distance_function    cellular_jitter    cellular_return_type    domain_warp_enabled    domain_warp_type    domain_warp_amplitude    domain_warp_frequency    domain_warp_fractal_type    domain_warp_fractal_octaves    domain_warp_fractal_lacunarity    domain_warp_fractal_gain    script    width    height    invert    in_3d_space    generate_mipmaps 	   seamless    seamless_blend_skirt    as_normal_map    bump_strength 
   normalize    color_ramp    noise    output_port_for_preview    default_input_values    expanded_output_ports    linked_parent_graph_frame    source    texture    texture_type    parameter_name 
   qualifier    hint    min    max    step    default_value_enabled    default_value    op_type    code    graph_offset    mode    modes/blend    flags/skip_vertex_transform    flags/unshaded    flags/light_only    flags/world_vertex_coords    nodes/vertex/0/position    nodes/vertex/connections    nodes/fragment/0/position    nodes/fragment/2/node    nodes/fragment/2/position    nodes/fragment/3/node    nodes/fragment/3/position    nodes/fragment/4/node    nodes/fragment/4/position    nodes/fragment/5/node    nodes/fragment/5/position    nodes/fragment/connections    nodes/light/0/position    nodes/light/connections    nodes/start/0/position    nodes/start/connections    nodes/process/0/position    nodes/process/connections    nodes/collide/0/position    nodes/collide/connections    nodes/start_custom/0/position    nodes/start_custom/connections     nodes/process_custom/0/position !   nodes/process_custom/connections    nodes/sky/0/position    nodes/sky/connections    nodes/fog/0/position    nodes/fog/connections           local://FastNoiseLite_rfvth ~	         local://NoiseTexture2D_lj6pb �	      &   local://VisualShaderNodeTexture_7cmhf +
      -   local://VisualShaderNodeFloatParameter_mkevb c
      .   local://VisualShaderNodeVectorDecompose_ywdov �
      #   local://VisualShaderNodeStep_svgq7 %      -   res://src/world/levels/level_fade_shader.res J         FastNoiseLite                            ����               ���A      �z�A         NoiseTexture2D                   �  #                      VisualShaderNodeTexture    )                     VisualShaderNodeFloatParameter    +         fadeAmount -         1                   VisualShaderNodeVectorDecompose    %                                   3                  VisualShaderNodeStep             VisualShader    4      �  shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D tex_frg_2;
uniform float fadeAmount : hint_range(0.0, 1.0) = 0.0;



void fragment() {
// Texture2D:2
	vec4 n_out2p0 = texture(tex_frg_2, UV);


// VectorDecompose:4
	float n_out4p0 = n_out2p0.x;
	float n_out4p1 = n_out2p0.y;
	float n_out4p2 = n_out2p0.z;
	float n_out4p3 = n_out2p0.w;


// FloatParameter:3
	float n_out3p0 = fadeAmount;


// Step:5
	float n_out5p0 = step(n_out4p0, n_out3p0);


// Output:0
	COLOR.a = n_out5p0;


}
 6         :          ?            @   
     ��  �CA            B   
    ���  ��C            D   
     /�  �CE            F   
     ��  4CG                                                                       RSRC