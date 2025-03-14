Shader "Unlit/Random0"
{
    Properties // input data
    {
        _colorScale ("Color Scale", float) = 1
        _timeScale ("Time Scale", float) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent" // tag to inform what type this is
            "Queue"="Transparent" // tag to change the render order
        }

        Pass
        {
            Blend One One
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _colorScale;
            float _timeScale;

            float rand_1_05(in float2 uv)
            {
                float2 noise = (frac(sin(dot(uv, float2(12.9898, 78.233) * 2.0)) * 43758.5453));
                return abs(noise.x + noise.y) * 0.5;
            }

            float2 rand_2_10(in float2 uv)
            {
                float noiseX = (frac(sin(dot(uv, float2(12.9898, 78.233) * 2.0)) * 43758.5453));
                float noiseY = sqrt(1 - noiseX * noiseX);
                return float2(noiseX, noiseY);
            }

            float2 rand_2_0004(in float2 uv)
            {
                float noiseX = (frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453));
                float noiseY = (frac(sin(dot(uv, float2(12.9898, 78.233) * 2.0)) * 43758.5453));
                return float2(noiseX, noiseY) * 0.004;
            }

            struct appdata
            {

                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal; 
                o.normal = UnityObjectToWorldNormal(o.normal); 

                o.uv = v.uv0;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float2 randCoord = rand_2_0004(i.uv * _timeScale * unity_DeltaTime * 0.00000001f) * _colorScale;
                float randVal = rand_1_05(i.uv * _timeScale * unity_DeltaTime * 0.00000001f) * _colorScale;
                float4 rand = float4(randVal, randVal, randVal, randVal);
                //float4 randNorm = float4(rand_2_0004(i.uv) * _colorScale, 0, 1);

                return rand;
            }
            ENDCG
        }
    }
}