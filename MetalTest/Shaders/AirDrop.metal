//
//  AirDrop.metal
//  MetalTest
//
//  Created by Tom on 10/7/23.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]] half4 airdrop(float2 position, SwiftUI::Layer layer, float t, float2 viewSize) {
  float2 position_yflip = float2(position.x, viewSize.y - position.y);
  float uv_y_dynamic_island_offset = 0.46;
  
  float t2 = pow(t, 2);
  float t3 = pow(t, 3);
  
  // Normalized pixel coordinates (from 0 to 1)
  float2 uv = position_yflip / viewSize;
  float2 uv_stretch = float2(uv.x+((uv.x-0.5)*pow(uv.y,6)*t3*0.1), uv.y * (uv.y * pow((1-(t2*0.01)), 8.0)) + (1-uv.y) * uv.y);
  uv_stretch = mix(uv, uv_stretch, smoothstep(1.1, 1.0, t));
  float4 color = float4(layer.sample(uv_stretch * viewSize));
  
  float2 bang_offset = float2(0.0);
  float bang_d = 0.0;
  if (t >= 1.0) {
    float aT = t - 1.0;
    float2 uv2 = uv;
    uv2 -= 0.5;
    uv2.x *= viewSize.x / viewSize.y;
    uv2.x -= 0.1;
    
    float2 uv_bang = float2(uv2.x, uv2.y);
    float2 uv_bang_origin = float2(uv_bang.x, uv_bang.y-uv_y_dynamic_island_offset);
    bang_d = (aT*0.16)/length(uv_bang_origin);
    bang_d = smoothstep(0.09, 0.05, bang_d) * smoothstep(0.04, 0.07, bang_d) * (uv.y+0.05);
    bang_offset = float2(-8.0*bang_d*uv2.x, -4.0*bang_d*(uv2.y-0.4))*0.1;
    
    float bang_d2 = ((aT-0.085) * 0.14)/length(uv_bang_origin);
    bang_d2 = smoothstep(0.09, 0.05, bang_d2) * smoothstep(0.04, 0.07, bang_d2) * (uv.y+0.05);
    bang_offset += float2(-8.0*bang_d2*uv2.x, -4.0*bang_d2*(uv2.y-0.4))*-0.02;
  }
  
  float2 uv_stretch_bang = uv_stretch+bang_offset;
  color = float4(layer.sample(uv_stretch_bang * viewSize));
  color += bang_d*500.0 * smoothstep(1.05, 1.1, t);
  
  float Pi = 6.28318530718 * 2;
  float Directions = 60.0;
  float Quality = 10.0;
  float Radius = t2*0.1 * pow(uv.y, 6.0) * 0.5;
  Radius *= smoothstep(1.3, 0.9, t);
  Radius += bang_d*0.05;
  // Blur calculations
  for( float d=0.0; d<Pi; d+=Pi/Directions)
  {
    for(float i=1.0/Quality; i<=1.0; i+=1.0/Quality)
    {
      float2 blurPos = (uv_stretch_bang + float2(cos(d),sin(d))*Radius*i);
      color += float4(layer.sample(blurPos*viewSize));
    }
  }
  color /= Quality * Directions;
  
  uv -= 0.5;
  uv.x *= viewSize.x / viewSize.y;
  uv.x -= 0.1;
  
  float2 lighten_uv = float2(uv.x*0.65, uv.y - t + 0.5);
  float d = smoothstep(0, 0.6, 0.1/length(lighten_uv)-uv_y_dynamic_island_offset)*0.25;
  float t_smooth = smoothstep(0.0, 0.3, t);
  d *= t_smooth;
  color = color + float4(color.r*d, color.g*d, 0.0, 1.0); // yellow blob
  
  float2 lighten2_uv = float2(uv.x*0.4, uv.y-uv_y_dynamic_island_offset);
  float d2 = smoothstep(0, 0.5, pow(1-length(lighten2_uv), 28))*0.5;
  float t2_smooth = smoothstep(0.0, 1.0, t2)*1.;
  d2 *= t2_smooth;
  d2 *= smoothstep(1.13, 1.0, t);
  color = float4(color.rgb*(1-d2), 1.0) + float4(float3(d2), 1.0); // white blob
  
  return half4(color);
}


