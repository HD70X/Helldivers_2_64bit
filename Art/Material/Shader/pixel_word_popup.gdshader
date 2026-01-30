shader_type canvas_item;

uniform vec4 text_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 top_outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 bottom_outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform int outline_width : hint_range(1, 10) = 4;

void fragment() {
    vec4 original_color = texture(TEXTURE, UV);
    vec4 result = original_color;
    result.rgb *= text_color.rgb;
    
    // 如果当前像素不透明，检测是否需要绘制上描边（内描边）
    if (original_color.a > 0.5) {
        bool is_top_edge = false;
        for (int i = 1; i <= outline_width; i++) {
            vec2 check_uv = UV + vec2(0.0, -float(i)) * TEXTURE_PIXEL_SIZE;
            if (texture(TEXTURE, check_uv).a < 0.5) {
                is_top_edge = true;
                break;
            }
        }
        if (is_top_edge) {
            result = top_outline_color;
        }
    }
    
    // 如果当前像素透明，检测是否需要绘制下投影（外投影）
    if (original_color.a < 0.5) {
        bool should_draw_shadow = false;
        for (int i = 1; i <= outline_width; i++) {
            vec2 check_uv = UV + vec2(0.0, -float(i)) * TEXTURE_PIXEL_SIZE;
            if (texture(TEXTURE, check_uv).a > 0.5) {
                should_draw_shadow = true;
                break;
            }
        }
        if (should_draw_shadow) {
            result = bottom_outline_color;
        }
    }
    
    COLOR = result;
}