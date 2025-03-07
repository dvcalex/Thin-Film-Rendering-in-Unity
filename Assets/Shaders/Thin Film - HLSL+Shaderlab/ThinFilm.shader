// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld' 
// WOAH THAT'S SO COOL ^^^

Shader "Custom/ThinFilm"
{
    Properties
    {
        //_hdrEnv ("HDR Environment Texture", 2D) = "white" {} // environment map
        _MainTex ("Texture", 2D) = "white" {}
        //_tData ("Data Texture", 2D) = "white" { } // data texture for thin film
        _tonemapFlag ("Tonemap Flag", Int) = 0
        _exposure ("Exposure", Float) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            #define saturate(a) clamp(a, 0.0, 1.0)
            #define one_over_pi_by_2 0.63661977236

            //sampler2D _hdrEnv;
            //float4 _hdrEnv_HDR;
            //sampler2D _tData;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            int _tonemapFlag;
            float _exposure;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float3 worldToCamDir : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldRefl : TEXCOORD2;
                float4 pos : SV_POSITION; // used as output from the shader
            };

            float3 tonemap(float3 color)
            {
                if (_tonemapFlag == 0)
                    return color;
                color *= _exposure;
                return saturate(color); // clamp(color, 0, 1)
            }

            float3 GetCube(float3 _vector, half _smoothness)
            {
                float mip = _smoothness * 6.0;
                float4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, _vector, mip);
                return DecodeHDR(rgbm, unity_SpecCube0_HDR);
            }

            v2f vert (appdata v)
            {
                v2f o;
                // vertex output from the shader
                o.pos = UnityObjectToClipPos(v.vertex);
                
                // compute world space position of the vertex
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                
                // get normalized direction from world vertex position to camera position
                //      UnityWorldSpaceViewDir(worldPos) == (_WorldSpaceCameraPos.xyz - worldPos)
                float3 worldToCamDir = normalize(UnityWorldSpaceViewDir(worldPos));
                o.worldToCamDir = worldToCamDir;
                
                // world space normal
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = worldNormal;
                
                // world space reflection vector
                o.worldRefl = reflect(-worldToCamDir, worldNormal);
                
                return o;
            }
        
            fixed4 frag (v2f i) : SV_Target
            {
                float3 envColor = GetCube(i.worldRefl, 0);

                // Calculate incident angle in worldspace
                float incidentAngle = acos(dot(i.worldToCamDir, i.worldNormal));
                
                float4 c = 0;
                c.rgb = envColor;
                // sample data texture for coat layers
                c.rgb *= tex2D(_MainTex, float2(incidentAngle * one_over_pi_by_2, 0)).rgb;
                c = float4(tonemap(c), 1);
                return c;
            }
            ENDCG
        }
    }
}
