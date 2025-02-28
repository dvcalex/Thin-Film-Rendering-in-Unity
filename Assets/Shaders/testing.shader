Shader "Custom/testing"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Include Unity shader utilities (for common functionality)
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;  // Vertex position (object space)
                float3 normal : NORMAL;    // Vertex normal (object space)
                float2 uv : TEXCOORD0;     // Vertex UV
            };

            struct v2f
            {
                float4 pos : SV_POSITION;  // Final position for rasterization (clip space)
                float3 normal : NORMAL;    // Normal to pass to fragment shader
                float2 uv : TEXCOORD0;     // UV to pass to fragment shader
            };

            // Uniforms (mappings to shader properties or Unity built-ins)
            uniform float4x4 modelViewMatrix;  // View matrix (camera transformation)
            uniform float4x4 projectionMatrix; // Projection matrix
            uniform float4x4 modelMatrix;      // Model matrix (object transformation)
            uniform float3x3 normalMatrix;    // Normal matrix (derived from model matrix)

            v2f vert(appdata v)
            {
                v2f o;

                // Calculate normal matrix (inverse transpose of model matrix)
                // In Unity, use UNITY_MATRIX_IT_MV for the normal matrix, if model matrix is Unity's matrix
                o.normal = normalize(mul(normalMatrix, v.normal)); // Transform normal to view space

                // Position transformation
                float4 worldPos = mul(modelMatrix, v.vertex);  // Transform position from object to world space
                o.pos = mul(projectionMatrix, mul(modelViewMatrix, worldPos)); // Transform position from world space to clip space

                o.uv = v.uv;  // Pass UVs to the fragment shader

                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                // Example fragment shader - just output the color (this can be customized)
                return half4(1, 1, 1, 1);  // White color for now
            }

            ENDCG
        }
    }
}
