//extern number iTime;
extern vec2 screen;
extern vec2 mouse_pos;

// Function to calculate the signed distance to a cube
float sdBox(vec3 p, vec3 b)
{
    vec3 d = abs(p) - b;
    return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}


vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){

    //center (0,0) with scaling
    vec2 uv = (screen_coords * 2.0 - screen) / screen.y;
    vec2 mouse = (mouse_pos * 2.0 - screen) / screen.y;
    uv.y = uv.y * -1.0;
    mouse.y = mouse.y * -1.0;


    vec4 fragColor = vec4(0.0, 0.0,0.0, 1);
    
    // Define the size of the cube
    vec3 cubeSize = vec3(0.2);
    
    // Define the position of the cube
    vec3 cubePosition = vec3(mouse.x, mouse.y, 0.0);
    
    // Calculate the distance from the current pixel to the cube
    float dist = sdBox(vec3(uv, 0.0) - cubePosition, cubeSize);
    
    // Define a threshold to determine if the pixel is inside or outside the cube
    float threshold = 0.01;
    
    // Set the color based on whether the pixel is inside or outside the cube
    vec3 c = dist < threshold ? vec3(1.0) : vec3(0.0);
    
    // Output the final color
    fragColor = vec4(c, 1.0);


    return fragColor;
}

