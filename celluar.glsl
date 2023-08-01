
// based on https://www.shadertoy.com/view/tscGRB

// All components are in the range [0…1], including hue.
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

int xorshift(in int value) // For random number generation
{
    // Xorshift*32
    // Based on George Marsaglia's work: http://www.jstatsoft.org/v08/i14/paper
    value ^= value << 13;
    value ^= value >> 17;
    value ^= value << 5;
    return value;
}

int nextInt(inout int seed)  // RNG
{
    seed = xorshift(seed);
    return seed;
}

float nextFloat(inout int seed) // RNG
{
    seed = xorshift(seed);
    return abs(fract(float(seed) / 31416.592898653));
}

float nextFloat(inout int seed, in float max) // RNG
{
    return nextFloat(seed) * max;
}

vec3 nearby(in vec2 fragCoord, in vec2 offset) // For getting pixels from prev. frame
{
    vec2 uv = (fragCoord + offset)/iResolution.xy;
    return vec3(texture(iChannel0, uv));
}


float hueDiff(in float a, in float b) // Finds the shortest difference between two hues
{	
    float diff=fract(a)-fract(b);
    if(abs(diff)<0.5)
        return diff;
    else
        return diff - 1.*sign(diff);
}

float checkfunction(in float near_hue, in float prev_hue) // used to determine the likelyhood of a pixel moving
{
    return (sign(hueDiff(near_hue,prev_hue)) + 4.*hueDiff(near_hue,prev_hue))/abs(hueDiff(near_hue,prev_hue));
}



const float threshold = 0.1; // Amount of randomness



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    int rngSeed = int(fragCoord.x) + int(fragCoord.y) * int(iResolution.x) + int(iTime * 10.0);
	
    float mouseDown = iMouse.z;
    vec2 uvMouse = vec2(iMouse)/iResolution.xy;

    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    vec3 previous = rgb2hsv(vec3(texture(iChannel0, uv)));
    vec3 next = previous;
    
    
    if(next[2]>0.05)    // Slowly fade un-updated pixels to black 
    	next[2]*=0.99;
    else
    {
    	if(nextFloat(rngSeed, 1.0)>0.9) // Seed some randomness to stop it from dying
        {
         	next[2]=1.;
            next[0]=nextFloat(rngSeed, 1.0);
            next[1]=1.;
                
        }
    }
    
    
    if(nextFloat(rngSeed, 1.0) > threshold) // randomly update pixels
    {
        
        // Adjacent pixles
        vec3 up = rgb2hsv(nearby(fragCoord, vec2(0.0, -1.0)));
        vec3 down = rgb2hsv(nearby(fragCoord, vec2(0.0, 1.0)));
        vec3 left = rgb2hsv(nearby(fragCoord, vec2(-1.0, 0.0)));
        vec3 right = rgb2hsv(nearby(fragCoord, vec2(1.0, 0.0)));
        
        // NOTE: everything is now [hue, sat, val] rather than [red, green, blue]
        
        // Weights of this pixel becoming the same color as one of the adjacents
        float upweight = up[1]*(abs(hueDiff(up[0],previous[0]))-0.3)*(0.7-abs(hueDiff(up[0],previous[0])))*(0.1+0.6*up[2])*checkfunction(up[0],previous[0]);
        float downweight = down[1]*(abs(hueDiff(down[0],previous[0]))-0.3)*(0.7-abs(hueDiff(down[0],previous[0])))*(0.1+0.6*down[2])*checkfunction(down[0],previous[0]);
        float leftweight = left[1]*(abs(hueDiff(left[0],previous[0]))-0.3)*(0.7-abs(hueDiff(left[0],previous[0])))*(0.1+0.6*left[2])*checkfunction(left[0],previous[0]);
        float rightweight = right[1]*(abs(hueDiff(right[0],previous[0]))-0.3)*(0.7-abs(hueDiff(right[0],previous[0])))*(0.1+0.6*right[2])*checkfunction(right[0],previous[0]);
        float _max = max(max(upweight,downweight),max(leftweight,rightweight));
		
        // Only update if the best option is strong enough
        if(_max>((previous[2]))*1.7)
        {
            if( _max == upweight)
                next = up;
            
            if (_max == downweight)
                next = down;

            if (_max == leftweight)
                next = left;

            if (_max == rightweight)
                next = right;
            // Inject some saturation and lightness to new pixles
            if(next[2]<1.)
                next[2]+=0.5+0.5*(abs(hueDiff(next[0],previous[0]))-1.);
            if(next[1]<1.)
                next[1]+=0.0003; 
        }
        else // make pixels diffuse if they can't update. Stops single-pixel islands
        {
            vec3 up_rgb = (nearby(fragCoord, vec2(0.0, -1.0)));
            vec3 down_rgb = (nearby(fragCoord, vec2(0.0, 1.0)));
            vec3 left_rgb = (nearby(fragCoord, vec2(-1.0, 0.0)));
            vec3 right_rgb = (nearby(fragCoord, vec2(1.0, 0.0)));
            vec3 prev_rgb = vec3(texture(iChannel0, uv));
            next = rgb2hsv(prev_rgb*0.9 + 0.1*(up_rgb+down_rgb+left_rgb+right_rgb)/4.);
        }
    }

	// use the webcam for the first frame
    if((iFrame < 5) || mouseDown>0.5) 
    {
        next = rgb2hsv(vec3(texture(iChannel1,uv)));
        previous = next;
        
    }
    

    // Output to screen
    fragColor = mix(vec4(hsv2rgb(next),1.0), texture(iChannel1,uv), .015);
}

