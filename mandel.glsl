extern number iTime;
extern vec2 screen;

const float MAX_ITER = 	128.0;

vec3 hash13(float m){
    float x = fract(sin(m)* 5625.246);
    float y = fract(sin(m + x)* 2216.486);
    float z = fract(sin(x + y)* 8276.352);

    return vec3(x,y,z);
}


float mandelbrot(vec2 uv){
    vec2 c = 5.0 * uv - vec2(0.7, 0.0);
    c = c / pow(iTime, 2.0) - vec2(0.65, 0.45);
    vec2 z = vec2(0.0); 
    float iter = 0.0;

    for(float i; i < MAX_ITER; i++){
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;

        if (dot(z, z) > 4.0){
            return iter / MAX_ITER;
        } 
        iter++;

    }
    return 0.0;
}


vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){

    vec2 uv = (screen_coords * 2.0 - screen) / screen.y;
    uv.y = uv.y * -1.0;

    vec3 finalColor = vec3(0.0);

    float m = mandelbrot(uv);
    finalColor += hash13(m); 

    //finalColor = pow(finalColor, vec3(0.45));

    vec4 pixelColor = vec4(finalColor, 1.0);
    return pixelColor;
}