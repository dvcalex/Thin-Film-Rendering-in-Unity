Shader "Unlit/thinFilm_unlit"
{
    Properties
    {
        _tEnv ("Cube Map Texture", Cube) = "" { } // environment cubemap
        _tData ("Data Texture", 2D) = "white" { } // main texture
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

            #include "UnityCG.cginc"

            #define saturate(a) clamp(a, 0.0, 1.0)
            #define one_over_pi_by_2 0.63661977236

            // "Properties" field declarations
            samplerCUBE _tEnv;
            sampler2D _tData;
            int _tonemapFlag;
            float _exposure;
            
            // supplied by Unity
            struct appdata
            {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 position : SV_POSITION; // output position for frag
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 vPosition : TEXCOORD2;
            };

            // Custom function
            float3 tonemap(float3 color)
            {
                if (_tonemapFlag == 0)
                    return color;
                color *= _exposure;
                return saturate(color); // clamp(color, 0, 1)
            }
            

            v2f vert(appdata v)
            {
                v2f o;
                // how do these work
                o.position = UnityObjectToClipPos(v.position);
                o.uv = v.uv;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.vPosition = UnityObjectToViewPos(v.position);

                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                // normalize our input vectors
                float3 viewDirection = normalize(i.vPosition);
                //float4 viewNormal = unity_WorldToCamera * float4(i.normal, 0.0);
                //float3 normal = normalize(viewNormal.xyz);
                
                //float incidentAngle = acos(dot(-viewDirection, normal)); // incident angle calculation

                // i = incidentAngle
                // n = normal
                // reflection vector found using the following formula: v = i - 2 * n * dot(i*n) .
                //float3 reflectDirection = -reflect(viewDirection, normal);

                // transform reflection vector to world space
                // dot product of columns 1-3 of WorlToCamera matrix with reflection vector
                //unity_CameraToWorld
                float x = -dot(unity_WorldToCamera[0], i.normal);
                float y = dot(unity_WorldToCamera[1], i.normal);
                float z = dot(unity_WorldToCamera[2], i.normal);
                float3 reflectDirectionWorld = float3(x, y, z);
                reflectDirectionWorld = normalize(reflectDirectionWorld);
                
                
                float3 vColor = texCUBE(_tEnv, reflectDirectionWorld).rgb /** tex2D(_tData, float2(incidentAngle * one_over_pi_by_2, 0.5)).rgb*/;
                float4 fragColor = float4(tonemap(vColor), 1);
                return fragColor;
            }
            ENDCG
        }
    }
}