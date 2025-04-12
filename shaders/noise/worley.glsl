extern number iTime;
extern vec2 screen;

vec2 Hash(vec2 P)
{
 	return fract(cos(P*mat2(-64.2,71.3,81.4,-29.8))*8321.3); 
}

float Worley(vec2 P)
{
    float Dist = 1.;
    vec2 I = floor(P);
    vec2 F = fract(P);
    
    for(int X = -1;X<=1;X++)
    for(int Y = -1;Y<=1;Y++)
    {
        float D = distance(Hash(I+vec2(X,Y))+vec2(X,Y),F);
        Dist = min(Dist,D);
    }
    return Dist;
	
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){

    //center (0,0) with scaling
    vec2 uv = (screen_coords * 2.0 - screen) / screen.y;
    uv.y = uv.y * -1.0;

    vec4 pixelColor = vec4(vec3(Worley(uv*10+iTime)),1.0);;
    return pixelColor;
}