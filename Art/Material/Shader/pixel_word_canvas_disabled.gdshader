shader_type canvas_item;

uniform vec4 text_color : source_color = vec4(1.0);
uniform vec4 top_outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 bottom_outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform int outline_width : hint_range(1, 10) = 4;
// 获取 CanvasGroup 渲染的内容
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest; 

void fragment() {
    // 采样当前像素
    vec4 original_color = texture(screen_texture, SCREEN_UV);
    vec4 result = original_color;
    
    // 像素字体必须用精确的 Alpha 判断
    bool is_solid = original_color.a > 0.1;

    if (is_solid) {
        // 内描边逻辑
        bool is_top_edge = false;
        for (int i = 1; i <= outline_width; i++) {
            // 注意：CanvasGroup 模式下，偏移量需参考 SCREEN_PIXEL_SIZE
            vec2 check_uv = SCREEN_UV + vec2(0.0, -float(i)) * SCREEN_PIXEL_SIZE;
            if (texture(screen_texture, check_uv).a < 0.1) {
                is_top_edge = true;
                break;
            }
        }
        if (is_top_edge) result = top_outline_color;
        else result.rgb *= text_color.rgb;
    } else {
        // 外投影逻辑
        bool should_draw_shadow = false;
        for (int i = 1; i <= outline_width; i++) {
            vec2 check_uv = SCREEN_UV + vec2(0.0, -float(i)) * SCREEN_PIXEL_SIZE;
            if (texture(screen_texture, check_uv).a > 0.1) {
                should_draw_shadow = true;
                break;
            }
        }
        if (should_draw_shadow) result = bottom_outline_color;
    }
    
    COLOR = result;
}
