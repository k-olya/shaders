// based on https://www.shadertoy.com/view/Nttyz4

// variant of https://shadertoy.com/view/7t3yzN

#define keyToggle(a)  ( texelFetch(iChannel3,ivec2(a,2),0).x > 0.)
#define S(v)            smoothstep(1., 0., abs(v)/fwidth(v) )

#define T(U)  texture(iChannel1,U) * ( keyToggle(9) ? 1. + vec4(.07,.03,0,0) + vec4(.6,.2,.2,0)*V.x + vec4(.18,.18,.18,0)*V.y : vec4(1) )

void mainImage( out vec4 O, vec2 u )
{
    vec2 R = iResolution.xy,
         U = u/R,
         G = R/ ( iMouse.xy==vec2(0) ? 8. : exp2(round(2.+4.*iMouse.y/R.y)) ),
         I = round (U*G)/G,
         V = 2.*U-1.; V *= V;
  
    G = G*(U-I)+.5;

    O-=O;
    if keyToggle(32) O = T(U);
    
  
    vec4 P = T( vec2(U.x,I.y) );  // horizontal RGB profiles
    O = mix( O, vec4(1), S( G.y - length(P.rgb)/sqrt(3.) ) );
  
    //P = T( vec2(I.x,U.y) );       // vertical RGB profiles
    //O = mix( O, vec4(1), S( G.x - length(P.rgb)/sqrt(3.) ) );
    
    O = sqrt(O);                  // to sRGB
}