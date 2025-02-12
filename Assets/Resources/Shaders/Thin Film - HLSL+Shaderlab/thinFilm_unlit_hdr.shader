Shader "Unlit/thinFilm_unlit_hdr"
{
    Properties
    {
        _hdrEnv ("HDR Environment Texture", 2D) = "white" {} // environment map
        _tData ("Data Texture", 2D) = "white" { } // data texture for thin films
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
            //samplerCUBE _tEnv;

            sampler2D _hdrEnv;
            float4 _hdrEnv_HDR;
            sampler2D _tData;
            int _tonemapFlag;
            float _exposure;

             // If you just add _FrontTex_HDR to your shader, Unity will fill it in with the HDR data
            //float4 _FrontTex_HDR;

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
            };

            // Custom function
            float3 tonemap(float3 color)
            {
                if (_tonemapFlag == 0)
                    return color;
                color *= _exposure;
                return saturate(color); // clamp(color, 0, 1)
            }
            
            float4 hdr_cubemap_frag(v2f i, sampler2D smp, float4 smpDecode)
            {
                float4 tex = tex2D(smp, i.uv);
                float3 c = DecodeHDR(tex, smpDecode);
                //c = c * _Tint.rgb * unity_ColorSpaceDouble.rgb;
                c *= _exposure;
                return float4(c, 1);
            }
            

            v2f vert(appdata v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.position);
                o.uv = v.uv;
                o.normal = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                // normalize our input vectors
                float3 viewDirection = normalize(i.position);
                float3 normal = normalize(i.normal);
                
                float incidentAngle = acos(dot(-viewDirection, normal)); // incident angle calculation

                // i = incidentAngle
                // n = normal
                // reflection vector found using the following formula: v = i - 2 * n * dot(i*n) .
                float3 reflectDirection = reflect(viewDirection, normal);

                // transform reflection vector to world space
                // dot product of columns 1-3 of WorlToCamera matrix with reflection vector
                float x = -dot(unity_WorldToCamera[0], reflectDirection);
                float y = dot(unity_WorldToCamera[1], reflectDirection);
                float z = dot(unity_WorldToCamera[2], reflectDirection);
                float3 reflectDirectionWorld = float3(x, y, z);


                float4 sample = tex2D(_hdrEnv, reflectDirectionWorld);
                float3 c = DecodeHDR (sample, _hdrEnv_HDR);
                
                //float3 vColor = texCUBE(_tEnv, reflectDirectionWorld).rgb * tex2D(_tData, float2(incidentAngle * one_over_pi_by_2, 0.5)).rgb;
                float3 vColor = c * tex2D(_tData, float2(incidentAngle * one_over_pi_by_2, 0.5)).rgb;
                float4 fragColor = float4(tonemap(vColor), 1);
                return fragColor;
            }
            ENDCG
        }
    }
}