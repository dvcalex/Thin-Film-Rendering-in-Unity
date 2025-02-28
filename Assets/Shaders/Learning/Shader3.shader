Shader "Unlit/Shader3"
{
    Properties
    {
        _val1 ("Value 1", float) = 5
        _val2 ("Value 2", float) = 1
        _timeScale ("Time Scale", float) = 1
    }
    SubShader
    {
        // subshader tags
        Tags {
            "RenderType"="Transparent" // tag to inform what type this is
            "Queue"="Transparent" // tag to change the render order
        }
        Pass
        {
            // pass tags
            
            // blending mode:
            //      (src * A) + (dest * B)
            //      src = this frag shader output
            //      dest = anything behind shader in the world
            
            Blend One One // additive blending (src * 1) + (dest * 1)
            //Blend DstColor Zero // multiply blending (src * dest) + (dest * 0)
            
            ZWrite Off // skip writing to the depth buffer (so it doesnt block objects behind it)
            
            //Cull Back // default backface culling
            //Cull Front // only culls the front-facing fragments
            Cull Off // renders both sides
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.28318530718
            
            float _val1;
            float _val2;
            float _timeScale;
            
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
                float offset = cos( (i.uv.x) * TAU * _val2) * 0.01;
                float t = cos( (i.uv.y + offset - _Time.y * _timeScale) * TAU * _val1 ) * 0.5 + 0.5;
                t *= (1 - i.uv.y);
                t *= (abs(i.normal.y) < 0.999);
                
                return t;
            }
            ENDCG
        }
    }
}
