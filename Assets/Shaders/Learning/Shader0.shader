Shader "Unlit/Shader0"
{
    Properties // input data
    {
        _scale ("UV Scale", float) = 1
        _offset ("UV Offset", float) = 0
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

            float _scale;
            float _offset;

            // the per-vertex mesh data
            // values automatically filled in through Unity
            struct appdata 
            {
                // ':' is called a semantic, used to specially define variables for input / output
                
                float4 vertex : POSITION; // vertex position
                float3 normal : NORMAL; // vertex normal vector
                //float4 tangent : TANGENT;
                //float4 color : COLOR;
                float2 uv0 : TEXCOORD0; // uv coords
                //float2 uv1 : TEXCOORD1; // uv coords

                // you can use different uv channels for things like different texture maps
            };

            // data that gets passed from vertex to fragment shader
            struct v2f
            {
                // the TEXCOORD's here do not reflect actual uv channels, rather they are just
                //      any data that you want to pass to the frag shader. So, you can use a lot.
                float4 vertex : SV_POSITION; // clip space position
                float3 normal : TEXCOORD0; // remember: these semantics DO NOT correspond to the uv coords
                float2 uv : TEXCOORD1;
            };

           
            // vertex shader code.
            // runs for each vertex.
            // takes in mesh data and returns vertex (and other) data to the frag shader.
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // converts local space to clip space
                // if you did o.vertex = o.vertex; (ie. remove the above line), the shader will render to
                //      the clip or 'screen' space.

                o.normal = v.normal; // just pass normals from appdata to vert shader (eventually onto frag shader)
                o.normal = UnityObjectToWorldNormal(o.normal); // convert normals from object to worldspace

                o.uv = (v.uv0 + _offset) * _scale;
                
                return o;
            }

            //float (32 bit float) (float is good to use in practice)
            //half (16 bit float) (good for most things)
            //fixed (lower precision) (only useful in the -1 to 1 range)
            //float4 -> half4 -> fixed4
            //float4x4 (matrix)

            // Note: For optimization, think about wether the vertex shader or the fragment shader will
            //      will run more. Typically, you will have more pixels (frag shader) than vertices, so
            //      doing things in the vertex shader can be a common optimization.

            
            // the fragment shader takes in interpolated vertex data.
            // runs for each 'fragment' (which are sometimes just pixels).
            // essentially colors the mesh.
            // ': SV_Target' semantic is telling shader that it should output to the frame buffer.
            float4 frag (v2f i) : SV_Target
            {

                // swizling:
                // float4 red = float4(1, 0, 0, 1);
                // float4 green = red.grba; // or red.yxzw

                // throws float3 components into float4 and adds 1 to last component
                float4 normalColors = float4(i.normal, 1);
                float4 normalScaledOffset = (normalColors + _offset) * _scale;

                float4 uvColors = float4(i.uv, 0, 1);
                
                return normalScaledOffset;
                return uvColors; 
            }
            ENDCG
        }
    }
}
