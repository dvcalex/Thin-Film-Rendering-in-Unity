Shader "Unlit/professor-thinFilm_unlit"
{
    Properties
    {
        _tEnviro ("Cube Map", Cube) = "" { } // environment cubemap
        _tData ("Base Texture", 2D) = "white" { } // main texture
        _tonemapFlag ("Tonemap Flag", Int) = 0
        _exposure ("Exposure", Float) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog // make fog work

            #include "UnityCG.cginc"

            #define saturate(a) clamp(a, 0.0, 1.0)
            #define one_over_pi_by_2 0.63661977236

            // "Properties" field declarations
            samplerCUBE _tEnviro;
            sampler2D _tData;
            int _tonemapFlag;
            float _exposure;

            // Custom function
            float3 tonemap(float3 color)
            {
                if (_tonemapFlag == 0)
                    return color;
                color *= _exposure;
                return saturate(color);
            }

            // supplied by Unity
            struct appdata
            {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                UNITY_FOG_COORDS(1)

                float4 position : SV_POSITION; // output position for frag
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.position);
                o.uv = v.uv;
                o.normal = UnityObjectToWorldNormal(v.normal);

                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float3 viewDirection = normalize(i.position);
                float3 N = normalize(i.normal);
                float incidentAngle = acos(dot(-viewDirection, N));
                float3 reflectDirection = reflect(viewDirection, N);
                
                float x = -dot(unity_WorldToCamera[0], reflectDirection);
                float y = dot(unity_WorldToCamera[1], reflectDirection);
                float z = dot(unity_WorldToCamera[2], reflectDirection);
                float3 reflectDirectionWorld = float3(x, y, z);

                float3 vColor = texCUBE(_tEnviro, reflectDirectionWorld).rgb * tex2D(_tData, float2(incidentAngle * one_over_pi_by_2, 0.5)).rgb;
                float4 fragColor = float4(tonemap(vColor), 1);
                UNITY_APPLY_FOG(i.fogCoord, fragColor); // apply fog (?)
                return fragColor;
            }
            ENDCG
        }
    }
}