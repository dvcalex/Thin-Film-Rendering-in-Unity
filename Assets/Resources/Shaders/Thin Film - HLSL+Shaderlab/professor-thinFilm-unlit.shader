Shader "Unlit/professor-thinFilm_unlit"
{
    Properties
    {
        
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

            // "Properties" field declarations


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

            fixed4 frag(v2f i) : SV_Target
            {
                // color output
                fixed4 col = fixed4(1, 1, 1, 1);

                
                
                UNITY_APPLY_FOG(i.fogCoord, col); // apply fog
                return col;
            }
            ENDCG
        }
    }
}