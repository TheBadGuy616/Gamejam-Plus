shader_type canvas_item;

// A cor que queremos para a borda
uniform vec4 border_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Vermelho
// A "dureza" da borda
uniform float hardness : hint_range(0.0, 1.0) = 0.3;
// Este é o valor que vamos animar!
uniform float fade_alpha : hint_range(0.0, 1.0) = 0.0; // Começa 100% transparente

void fragment() {
    // Calcula a distância do pixel atual até o centro da tela (0.5, 0.5)
    float dist = distance(UV, vec2(0.5));
    
    // Calcula a vinheta. 
    // AGORA: 0.0 no centro (dist=0) e 1.0 nas bordas (dist=0.5)
    float borda = smoothstep(0.5 - hardness, 0.5, dist); // <-- LINHA CORRIGIDA
    
    // Define a cor final:
    COLOR = vec4(border_color.rgb, border_color.a * borda * fade_alpha);
}