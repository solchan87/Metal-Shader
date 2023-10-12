//
//  tv.metal
//  MetalTest
//
//  Created by Tom on 10/8/23.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

half4 scanline(float2 position, half4 screen, float time) {
  screen.rgb -= sin((position.y + (time * 29.0))) * 0.02;
  return half4(screen.rgb, screen.a);
}

float2 crt(float2 position, float bend) {
  position = (position - 0.5) * 2.0;
  position *= 1.1;
  
  position.x *= 1.0 + pow((abs(position.y) / bend), 2.0);
  position.y *= 1.0 + pow((abs(position.x) / bend), 2.0);
  
  position = (position / 2.0) + 0.5;
  return position;
}

half4 sampleSplit(SwiftUI::Layer layer, float2 position, float time) {
  half4 frag;
  frag.r = layer.sample(float2(position.x - 0.01 * sin(time), position.y)).r;
  frag.g = layer.sample(float2(position.x, position.y)).g;
  frag.b = layer.sample(float2(position.x + 0.01 * sin(time), position.y)).b;
  frag.a = layer.sample(position).a;
  return frag;
}

[[stitchable]] half4 crt(float2 position, SwiftUI::Layer layer, float4 bounds, float time) {
  float2 resolution = bounds.zw;
  float2 uv = position / resolution;
  uv.y = 1.0 - uv.y;
  float2 crtCoords = crt(uv, 4.2);
  
  if (crtCoords.x < 0.0 || crtCoords.x > 1.0 || crtCoords.y < 0.0 || crtCoords.y > 1.0)
          discard_fragment();
  
  half4 color = sampleSplit(layer, position, time);
  float2 screenSpace = crtCoords * resolution;
  color = scanline(screenSpace, color, time);
  
  return color;
}
