Shader "Unlit/Shader1"
{
    Properties
    {
        _colorA ("Color A", Color) = (1, 1, 1, 1)
        _colorB ("Color B", Color) = (1, 1, 1, 1)
        _colorStart ("Color Start", Range(0,1)) = 0
        _colorEnd ("Color End", Range(0,1)) = 1
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

            float4 _colorA;
            float4 _colorB;
            float _colorStart;
            float _colorEnd;
            
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
                // blend between color A and B based on x component of uv
                
                float t = InverseLerp(_colorStart, _colorEnd, i.uv.x);

                // clamp 0->1
                t = saturate(t);

                // frac: v - floor(v)
                //t = frac(t);
                
                float4 outColor = lerp(_colorA, _colorB, t);

                //return i.uv.x;
                return outColor;
            }
            ENDCG
        }
    }
}
