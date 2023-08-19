// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "GD/Cards/Card"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.91
		_CardBack("CardBack", 2D) = "white" {}
		_SmoothnessMetallic("Smoothness Metallic", 2D) = "white" {}
		_metallicamount("metallic amount", Float) = 0
		_ErosionTexture("Erosion Texture", 2D) = "white" {}
		_ErosionMask("Erosion Mask", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _CardBack;
		uniform float4 _CardBack_ST;
		uniform sampler2D _ErosionTexture;
		uniform float4 _ErosionTexture_ST;
		uniform float _ErosionMask;
		uniform sampler2D _SmoothnessMetallic;
		uniform float4 _SmoothnessMetallic_ST;
		uniform float _metallicamount;
		uniform float _Cutoff = 0.91;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_CardBack = i.uv_texcoord * _CardBack_ST.xy + _CardBack_ST.zw;
			float4 tex2DNode5 = tex2D( _CardBack, uv_CardBack );
			float2 appendResult45 = (float2(( 1.0 - i.uv_texcoord.x ) , i.uv_texcoord.y));
			float2 break11 = i.uv_texcoord;
			float2 _MaskCutoffs = float2(0.5,0.75);
			float temp_output_12_0 = step( break11.x , _MaskCutoffs.x );
			float lerpResult46 = lerp( tex2DNode5.a , tex2D( _CardBack, appendResult45 ).a , temp_output_12_0);
			float2 uv_ErosionTexture = i.uv_texcoord * _ErosionTexture_ST.xy + _ErosionTexture_ST.zw;
			SurfaceOutputStandard s37 = (SurfaceOutputStandard ) 0;
			s37.Albedo = tex2DNode5.rgb;
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			s37.Normal = ase_normWorldNormal;
			s37.Emission = float3( 0,0,0 );
			float2 uv_SmoothnessMetallic = i.uv_texcoord * _SmoothnessMetallic_ST.xy + _SmoothnessMetallic_ST.zw;
			float4 tex2DNode47 = tex2D( _SmoothnessMetallic, uv_SmoothnessMetallic );
			s37.Metallic = ( tex2DNode47.r * _metallicamount );
			s37.Smoothness = tex2DNode47.g;
			s37.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi37 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g37 = UnityGlossyEnvironmentSetup( s37.Smoothness, data.worldViewDir, s37.Normal, float3(0,0,0));
			gi37 = UnityGlobalIllumination( data, s37.Occlusion, s37.Normal, g37 );
			#endif

			float3 surfResult37 = LightingStandard ( s37, viewDir, gi37 ).rgb;
			surfResult37 += s37.Emission;

			#ifdef UNITY_PASS_FORWARDADD//37
			surfResult37 -= s37.Emission;
			#endif//37
			c.rgb = surfResult37;
			c.a = 1;
			clip( ( lerpResult46 * step( tex2D( _ErosionTexture, uv_ErosionTexture ).r , _ErosionMask ) ) - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;33;-3018.773,-756.5374;Inherit;False;1403.915;560.3519;Comment;12;34;16;32;25;26;23;29;22;24;15;39;55;Card Front UV;0.1100687,1,0,1;0;0
Node;AmplifyShaderEditor.StepOpNode;12;-754.4858,311.2468;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1398.933,330.2173;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;11;-1097.833,333.5348;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TextureCoordinatesNode;15;-2679.52,-531.6788;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;23;-2968.772,-624.3096;Inherit;False;Property;_Yindex;Y index;7;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-2175.744,-535.012;Inherit;False;4;4;0;FLOAT2;0,0;False;1;FLOAT2;0,-1;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;25;-2403.789,-486.7398;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;16;-1985.909,-381.5349;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-1829.591,-367.1408;Inherit;False;CardFrontUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StepOpNode;9;-762.4208,555.377;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;36;301.1901,120.2754;Inherit;False;Cel Lighting;-1;;2;008f75f771ee44164818b0444ef6361c;0;4;23;FLOAT4;1,1,1,1;False;5;FLOAT3;0.5,0.5,0.5;False;6;FLOAT;0;False;21;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomStandardSurface;37;228.3433,-198.707;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;24;-2610.679,-656.176;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;38;-2385.496,-298.6153;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.IntNode;22;-2968.773,-706.5374;Inherit;False;Property;_Xindex;X index;6;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;39;-2549.173,-335.2787;Inherit;False;Property;_Rows;Rows;4;0;Create;True;0;0;0;False;0;False;4;6;False;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;40;-2557.028,-244.9295;Inherit;False;Property;_Columns;Columns;5;0;Create;True;0;0;0;False;0;False;4;4;False;0;1;INT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;42;-448.5135,499.071;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;44;-229.4613,524.5424;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;45;-59.65332,538.1271;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;41;-8.710948,373.4129;Inherit;True;Property;_TextureSample2;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;14;40.37259,125.466;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;4;-877.124,108.9319;Inherit;True;Property;_CardBack;CardBack;2;0;Create;True;0;0;0;False;0;False;None;f2258ddf0341843feacf6ad5404bce8c;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;32;-2672.194,-411.2964;Inherit;False;31;MaskRes;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-1036.568,467.2698;Inherit;False;MaskRes;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;8;-1292.441,538.7715;Inherit;False;Constant;_MaskCutoffs;Mask Cutoffs;2;0;Create;True;0;0;0;False;0;False;0.5,0.75;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;3;-478.9951,-87.92604;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;47;-385.3398,-732.3677;Inherit;True;Property;_TextureSample3;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;2;-1190.495,-233.6595;Inherit;True;Property;_CardFront;CardFront;0;0;Create;True;0;0;0;False;0;False;None;c9a16f948e31148b5900298043435a1a;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;50;-839.6406,-327.0348;Inherit;True;Property;_TextureSample4;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;48;-802.3193,-643.3906;Inherit;True;Property;_SmoothnessMetallic;Smoothness Metallic;3;0;Create;True;0;0;0;False;0;False;None;48f3b9bdf93894b0787003e36810a8b9;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;53;-1056.856,89.16223;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;35;-1139.086,-23.86279;Inherit;False;34;CardFrontUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-1303.297,107.497;Inherit;False;Property;_Parallaxdepth;Parallax depth;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-2792.7,-622.6873;Inherit;False;2;2;0;INT;0;False;1;INT;-1;False;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-2771.879,-725.0058;Inherit;False;2;2;0;INT;0;False;1;INT;-1;False;1;INT;0
Node;AmplifyShaderEditor.ColorNode;56;-153.4082,-81.60364;Inherit;False;Property;_Color0;Color 0;10;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-550.046,113.5821;Inherit;True;Property;_TextureSample1;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;129.5676,-478.0382;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-79.00851,-271.0209;Inherit;False;Property;_metallicamount;metallic amount;8;0;Create;True;0;0;0;False;0;False;0;0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1210.375,-70.04344;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;GD/Cards/Card;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.91;True;True;0;True;TransparentCutout;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.LerpOp;46;313.9241,307.1881;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;775.7078,285.0206;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;61;732.5375,543.1843;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;60;-51.08247,676.9817;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;59;316.9924,603.6512;Inherit;True;Property;_ErosionTexture;Erosion Texture;11;0;Create;True;0;0;0;False;0;False;-1;None;7a051dbda2d7bc447bee412427cd311e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;63;150.2936,721.2545;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;62;509.8061,816.1112;Inherit;False;Property;_ErosionMask;Erosion Mask;12;0;Create;True;0;0;0;False;0;False;0;0.08;0;0;0;1;FLOAT;0
WireConnection;12;0;11;0
WireConnection;12;1;8;1
WireConnection;11;0;6;0
WireConnection;26;0;25;0
WireConnection;26;2;24;0
WireConnection;26;3;38;0
WireConnection;25;0;15;0
WireConnection;25;1;32;0
WireConnection;16;0;26;0
WireConnection;16;1;38;0
WireConnection;34;0;16;0
WireConnection;9;0;11;1
WireConnection;9;1;8;2
WireConnection;36;23;14;0
WireConnection;37;0;5;0
WireConnection;37;3;57;0
WireConnection;37;4;47;2
WireConnection;24;0;22;0
WireConnection;24;1;29;0
WireConnection;38;0;39;0
WireConnection;38;1;40;0
WireConnection;44;0;42;1
WireConnection;45;0;44;0
WireConnection;45;1;42;2
WireConnection;41;0;4;0
WireConnection;41;1;45;0
WireConnection;14;0;5;0
WireConnection;14;1;56;0
WireConnection;14;2;12;0
WireConnection;31;0;8;0
WireConnection;3;0;2;0
WireConnection;47;0;48;0
WireConnection;50;0;2;0
WireConnection;50;1;35;0
WireConnection;29;0;23;0
WireConnection;55;0;22;0
WireConnection;5;0;4;0
WireConnection;57;0;47;1
WireConnection;57;1;49;0
WireConnection;0;10;58;0
WireConnection;0;13;37;0
WireConnection;46;0;5;4
WireConnection;46;1;41;4
WireConnection;46;2;12;0
WireConnection;58;0;46;0
WireConnection;58;1;61;0
WireConnection;61;0;59;1
WireConnection;61;1;62;0
WireConnection;63;0;60;0
ASEEND*/
//CHKSM=6EB070CF040D8654FD427E2C847696A3B831AB09