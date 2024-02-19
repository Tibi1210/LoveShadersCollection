//extern number iTime;
extern vec2 screen;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){

    //center (0,0) with scaling
    vec2 uv = (screen_coords * 2.0 - screen) / screen.y;
    uv.y = uv.y * -1.0;
    vec3 finalColor = vec3(uv.x, uv.y, 1);


    vec4 pixelColor = vec4(finalColor, 1.0);
    return pixelColor;
}