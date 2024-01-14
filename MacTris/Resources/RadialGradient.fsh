
void main () {
    float pixel_distance = min(1.0, distance(v_tex_coord, vec2(0.5, 0.5)) * 2.0);
    float color = (1 - pixel_distance) * v_color_mix.a;
    gl_FragColor = vec4(color, color, color, 1);
}
