extern number iTime;
extern vec2 screen;

#define S(a, b, t) smoothstep(a, b, t)

float TaperBox(vec2 pos, float wb, float wt, float yb, float yt, float blur){

    float m = S(-blur, blur, pos.y - yb);
    m *= S(blur, -blur, pos.y - yt);
    
    pos.x = abs(pos.x);

    float w = mix(wb, wt, (pos.y - yb) / (yt - yb));
    m *= S(blur, -blur, pos.x - w);

    return m;
}

vec4 Tree(vec2 uv, vec3 col, float blur){

    float m = TaperBox(uv, 0.03, 0.03, -0.05, 0.25, blur); // trunk
    m += TaperBox(uv, 0.2, 0.1, 0.25, 0.5, blur); // cp bot
    m += TaperBox(uv, 0.15, 0.05, 0.5, 0.75, blur); // cp mid
    m += TaperBox(uv, 0.1, 0.0, 0.75, 1.0, blur); // cp top

    float shadow = TaperBox(uv - vec2(0.2,0), 0.1, 0.5, 0.15, 0.25, blur);
    shadow += TaperBox(uv + vec2(0.25,0), 0.1, 0.5, 0.45, 0.5, blur);
    shadow += TaperBox(uv - vec2(0.2,0), 0.1, 0.5, 0.7, 0.75, blur);

    col -= shadow * 0.8;


    return vec4(col, m);
}

float getHeight(float x){
    return sin(x * 0.546) + sin(x) * 0.3;
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){

    //center (0,0) with scaling
    vec2 uv = (screen_coords * 2.0 - screen) / screen.y;
    uv.y = uv.y * -1.0;
    //uv.y += 1; // shift x to bottom of screen
    uv.x += iTime*0.1;
    uv *= 4; // zoom out

    //coordinates
    //float thickness = 1.01/screen.y;
    //if(abs(uv.x)<thickness){
    //    finalColor.r = 1.0;
    //}
    //if(abs(uv.y)<thickness){
    //    finalColor.g = 1.0;
    //}

    vec4 finalColor = vec4(0.0);
    float blur = 0.005;

    float id = floor(uv.x);
    float n = fract(sin(id*234.12)*5438.3) * 2.0 - 1.0;

    vec2 transform = vec2(n * 0.3, getHeight(uv.x));
    vec2 scale = vec2(1,1.0 + n * 0.2);

    uv.x = fract(uv.x)-0.5;

    finalColor += S(blur, -blur, uv.y + transform.y); // ground

    transform.y = getHeight(id + 0.5 + transform.x) * -1.0;
    
    vec4 tree = Tree((uv - transform) * scale , vec3(1), blur);

    finalColor = mix(finalColor, tree, tree.a);






    return finalColor;
}