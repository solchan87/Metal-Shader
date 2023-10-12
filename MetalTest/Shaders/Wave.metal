//
//  Wave.metal
//  MetalTest
//
//  Created by Tom on 10/13/23.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] float2 wave(float2 position, float time) {
    float f = (time * 5.0);
    float s = (position.x / 30.0);
    float w = 0;
    w = sin(f - s);
  
    float positionY = position.y + w * 10.0;
  
    return float2(position.x, positionY);
}
