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
        _smoothness ("Smoothness", Float) = 1 // used to control "blurriness" of mirror
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
            float _smoothness;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float3 worldViewDir : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldRefl : TEXCOORD2;
                float4 pos : SV_POSITION;
            };

            float3 tonemap(float3 color)
            {
                if (_tonemapFlag == 0)
                    return color;
                color *= _exposure;
                return saturate(color); // clamp(color, 0, 1)
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                // compute world space position of the vertex
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                
                // compute world space view direction ((viewPos - worldPos) normalized)
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                o.worldViewDir = worldViewDir;
                
                // world space normal
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = worldNormal;
                
                // world space reflection vector
                o.worldRefl = reflect(-worldViewDir, worldNormal);
                
                return o;
            }
        
            fixed4 frag (v2f i) : SV_Target
            {
                float roughness = 1 - _smoothness;
                roughness *= 1.7 - 0.7 * roughness; // formula to convert roughness value into mipmap level

                /*
                 * TODO: I think unity_SpecCube0 is losing resolution somehow (look into SamplerState),
                 *      which makes reflection very low res.
                */
                
                // sample the default reflection cubemap, using the reflection vector
                float4 envSample = UNITY_SAMPLE_TEXCUBE_LOD(
                    unity_SpecCube0,
                    i.worldRefl,
                    roughness * 6 // use 6 as it is the value of UNITY_SPECCUBE_LOD_STEPS which is not included here for some reason
                    );
                
                // Calculate incident angle in worldspace
                float incidentAngle = acos(dot(-i.worldViewDir, i.worldNormal));
                
                // decode cubemap data into actual color
                float3 envColor = DecodeHDR(envSample, unity_SpecCube0_HDR);

                /*
                 * TODO: Convert the texture data into a texture format (or just slap in the data texture
                 *      arrays in the code instead of using _tData).
                */
                
                // color
                float4 c = 0;
                /*
                 * assuming tex2D sampler input is represented from (0,0)->(1,1),
                 *      then we are sample the y value in the middle (0.5f).
                */
                c.rgb = envColor;
                c.rgb *= tex2D(_MainTex, float2(incidentAngle * one_over_pi_by_2, 0)).rgb;
                c = float4(tonemap(c), 1);
                return c;
            }
            ENDCG
        }
    }
}
