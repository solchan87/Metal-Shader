//
//  Gradientify.metal
//  MetalTest
//
//  Created by Tom on 10/13/23.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 gradientify(
    float2 position,
    half4 color,
    float4 resolution,
    float time
) {
    vector_float2 uv = position/resolution.zw;
    vector_float3 col = 0.5 + 0.5 *cos(time + uv.xyx + float3(0, 2, 4));
    return half4(col.x, col.y, col.z, 1);
}
