//
//  CRT2.metal
//  MetalTest
//
//  Created by Tom on 10/13/23.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

float2 curve(float2 uv)
{
  uv = (uv - 0.5f) * 2.0f;
  uv *= 1.1f;
  uv.x *= 1.0f + pow((fabs(uv.y) / 5.0f), 2.0f);
  uv.y *= 1.0f + pow((fabs(uv.x) / 4.0f), 2.0f);
  uv = (uv / 2.0f) + 0.5f;
  uv = uv * 0.92f + 0.04f;
  return uv;
}

[[stitchable]] half4 newCrt(float2 position, SwiftUI::Layer layer, float4 bounds, float time) {
  constexpr sampler sampler(address::clamp_to_edge, filter::linear);
  
  float2 resolution = bounds.zw;
  float2 q = position / resolution;
  float2 uv = q;
  uv = curve(uv);
  half3 col;
  float x = sin(0.3f * time + uv.y * 21.0f) * sin(0.7f * time + uv.y * 29.0f) * sin(0.3f + 0.33f * time + uv.y * 31.0f) * 0.0017f;
  
  col.r = layer.tex.sample(sampler, float2(x + uv.x + 0.001f, uv.y + 0.001f)).x + 0.05f;
  col.g = layer.tex.sample(sampler, float2(x + uv.x, uv.y - 0.002f)).y + 0.05f;
  col.b = layer.tex.sample(sampler, float2(x + uv.x - 0.002f, uv.y)).z + 0.05f;
  col.r += 0.08f * layer.tex.sample(sampler, 0.75f * float2(x + 0.025f, -0.027f) + float2(uv.x + 0.001f, uv.y + 0.001f)).x;
  col.g += 0.05f * layer.tex.sample(sampler, 0.75f * float2(x - 0.022f, -0.02f) + float2(uv.x, uv.y - 0.002f)).y;
  col.b += 0.08f * layer.tex.sample(sampler, 0.75f * float2(x - 0.02f, -0.018f) + float2(uv.x - 0.002f, uv.y)).z;
  
  col = clamp(col * 0.6f + 0.4f * col * col * 1.0f, 0.0f, 1.0f);
  
  float vig = 0.0f + 1.0f * 16.0f * uv.x * uv.y * (1.0f - uv.x) * (1.0f - uv.y);
  col *= half3(pow(vig, 0.3f));
  
  col *= half3(0.95f, 1.05f, 0.95f);
  col *= 2.8f;
  
  float scans = clamp(0.35f + 0.35f * sin(3.5f * time + uv.y * resolution.y * 1.5f), 0.0f, 1.0f);
  float s = pow(scans, 1.7f);
  col = col * half3(0.4f + 0.7f * s);
  
  col *= 1.0f + 0.01f * sin(110.0f * time);
  
  if (uv.x < 0.0f || uv.x > 1.0f)
    col *= 0.0f;
  if (uv.y < 0.0f || uv.y > 1.0f)
    col *= 0.0f;
  
  col *= 1.0f - 0.65f * half3(clamp((fmod(position.x, 2.0f) - 1.0f) * 2.0f, 0.0, 1.0));
  
  return half4(col, 1.0f);
}
