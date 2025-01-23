Shader "Unlit/Shader2"
{
    Properties
    {
        _val ("Value", float) = 5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.28318530718
            
            float _val;
            
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.normal = v.normal;
                o.normal = UnityObjectToWorldNormal(o.normal);

                o.uv = v.uv0;
                
                return o;
            }

            float InverseLerp(float a, float b, float v)
            {
                return (v - a) / (b - a);
            }
            
            float4 frag (v2f i) : SV_Target
            {
                float t = i.uv.x;
                //float t = sqrt(pow(i.uv.x, 2) + pow(i.uv.y, 2));

                //float4 triangleWave = abs(frac(t * _val) * 2 - 1);
                //return triangleWave;

                float4 cosineWave = cos(t * _val * TAU); // will perfectly repeat with TAU value
                return cosineWave;
            }
            ENDCG
        }
    }
}
