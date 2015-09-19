//
//  Shaders.metal
//  Iron
//
//  Created by Rox Dorentus on 2015-9-15.
//  Copyright © 2015年 rubyist.today. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn{
    packed_float3 position;
    packed_float4 color;
};

struct VertexOut{
    float4 position [[position]];
    float4 color;
};

struct Uniforms{
    float4x4 modelMatrix;
    float4x4 projectionMatrix;
};

vertex VertexOut basic_vertex(
        const device VertexIn* vertex_array [[ buffer(0) ]],
        const device Uniforms& uniforms [[ buffer(1) ]],
        unsigned int vid [[ vertex_id ]]) {
    VertexIn vin = vertex_array[vid];
    float4x4 mm = uniforms.modelMatrix;
    float4x4 pm = uniforms.projectionMatrix;

    VertexOut vout;
    vout.position = pm * mm * float4(vin.position, 1);
    vout.color = vin.color;

    return vout;
}

fragment half4 basic_fragment(VertexOut interpolated [[stage_in]]) {
    return half4(interpolated.color[0], interpolated.color[1], interpolated.color[2], interpolated.color[3]);
}
