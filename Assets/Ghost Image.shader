// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "GD/Ghost Image"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_depthMap("depthMap", 2D) = "white" {}
		_Rows("Rows", Int) = 4
		_Columns("Columns", Int) = 4
		_Xindex("X index", Int) = 0
		_Yindex("Y index", Int) = 0
		_parallaxAmount("parallaxAmount", Range( 0 , 1)) = 0
		_curlAmount("curl Amount", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[Header(Parallax Occlusion Mapping)]
		_CurvFix("Curvature Bias", Range( 0 , 1)) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 viewDir;
			INTERNAL_DATA
			float3 worldNormal;
			float3 worldPos;
		};

		uniform float _curlAmount;
		uniform sampler2D _MainTex;
		uniform int _Xindex;
		uniform int _Yindex;
		uniform int _Rows;
		uniform int _Columns;
		uniform sampler2D _depthMap;
		uniform float _parallaxAmount;
		uniform float _CurvFix;
		uniform float4 _depthMap_ST;
		uniform float _Cutoff = 0.5;


		inline float2 POM( sampler2D heightMap, float2 uvs, float2 dx, float2 dy, float3 normalWorld, float3 viewWorld, float3 viewDirTan, int minSamples, int maxSamples, float parallax, float refPlane, float2 tilling, float2 curv, int index )
		{
			float3 result = 0;
			int stepIndex = 0;
			int numSteps = ( int )lerp( (float)maxSamples, (float)minSamples, saturate( dot( normalWorld, viewWorld ) ) );
			float layerHeight = 1.0 / numSteps;
			float2 plane = parallax * ( viewDirTan.xy / viewDirTan.z );
			uvs.xy += refPlane * plane;
			float2 deltaTex = -plane * layerHeight;
			float2 prevTexOffset = 0;
			float prevRayZ = 1.0f;
			float prevHeight = 0.0f;
			float2 currTexOffset = deltaTex;
			float currRayZ = 1.0f - layerHeight;
			float currHeight = 0.0f;
			float intersection = 0;
			float2 finalTexOffset = 0;
			while ( stepIndex < numSteps + 1 )
			{
			 	result.z = dot( curv, currTexOffset * currTexOffset );
			 	currHeight = tex2Dgrad( heightMap, uvs + currTexOffset, dx, dy ).g * ( 1 - result.z );
			 	if ( currHeight > currRayZ )
			 	{
			 	 	stepIndex = numSteps + 1;
			 	}
			 	else
			 	{
			 	 	stepIndex++;
			 	 	prevTexOffset = currTexOffset;
			 	 	prevRayZ = currRayZ;
			 	 	prevHeight = currHeight;
			 	 	currTexOffset += deltaTex;
			 	 	currRayZ -= layerHeight * ( 1 - result.z ) * (1+_CurvFix);
			 	}
			}
			int sectionSteps = 4;
			int sectionIndex = 0;
			float newZ = 0;
			float newHeight = 0;
			while ( sectionIndex < sectionSteps )
			{
			 	intersection = ( prevHeight - prevRayZ ) / ( prevHeight - currHeight + currRayZ - prevRayZ );
			 	finalTexOffset = prevTexOffset + intersection * deltaTex;
			 	newZ = prevRayZ - intersection * layerHeight;
			 	newHeight = tex2Dgrad( heightMap, uvs + finalTexOffset, dx, dy ).g;
			 	if ( newHeight > newZ )
			 	{
			 	 	currTexOffset = finalTexOffset;
			 	 	currHeight = newHeight;
			 	 	currRayZ = newZ;
			 	 	deltaTex = intersection * deltaTex;
			 	 	layerHeight = intersection * layerHeight;
			 	}
			 	else
			 	{
			 	 	prevTexOffset = finalTexOffset;
			 	 	prevHeight = newHeight;
			 	 	prevRayZ = newZ;
			 	 	deltaTex = ( 1 - intersection ) * deltaTex;
			 	 	layerHeight = ( 1 - intersection ) * layerHeight;
			 	}
			 	sectionIndex++;
			}
			#ifdef UNITY_PASS_SHADOWCASTER
			if ( unity_LightShadowBias.z == 0.0 )
			{
			#endif
			 	if ( result.z > 1 )
			 	 	clip( -1 );
			#ifdef UNITY_PASS_SHADOWCASTER
			}
			#endif
			return uvs.xy + finalTexOffset;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			float3 normalizeResult44 = normalize( ase_vertexNormal );
			v.vertex.xyz += ( v.texcoord.xy.y * ( _curlAmount * UNITY_PI ) * normalizeResult44 * v.texcoord.xy.y * v.texcoord.xy.y );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			float2 MaskRes18 = float2( 0.5,0.75 );
			float2 appendResult11 = (float2((float)_Xindex , (float)( _Yindex * -1 )));
			float2 appendResult13 = (float2((float)_Rows , (float)_Columns));
			float2 CardFrontUV10 = ( ( ( i.uv_texcoord / MaskRes18 ) + float2( -1,-1 ) + appendResult11 + appendResult13 ) / appendResult13 );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 OffsetPOM37 = POM( _depthMap, CardFrontUV10, ddx(CardFrontUV10), ddy(CardFrontUV10), ase_worldNormal, ase_worldViewDir, i.viewDir, 99, 99, ( _parallaxAmount * 0.05 ), 0.5, _depthMap_ST.xy, float2(0,0), 0 );
			float4 tex2DNode21 = tex2D( _MainTex, OffsetPOM37 );
			o.Albedo = tex2DNode21.rgb;
			o.Alpha = 1;
			float Alpha35 = tex2D( _MainTex, CardFrontUV10 ).a;
			float temp_output_36_0 = Alpha35;
			clip( temp_output_36_0 - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
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
Node;AmplifyShaderEditor.CommentaryNode;3;-1327.251,607.8444;Inherit;False;1403.915;560.3519;Comment;13;16;15;14;13;12;11;10;9;8;7;6;5;4;Card Front UV;0.1100687,1,0,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-987.9975,832.7032;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;5;-1277.25,740.0724;Inherit;False;Property;_Yindex;Y index;6;0;Create;True;0;0;0;False;0;False;0;2;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;7;-712.2664,877.6422;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;9;-294.3867,982.8471;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-138.0685,997.2412;Inherit;False;CardFrontUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;11;-919.1564,708.2059;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-1101.178,741.6946;Inherit;False;2;2;0;INT;0;False;1;INT;-1;False;1;INT;0
Node;AmplifyShaderEditor.DynamicAppendNode;13;-693.9734,1065.767;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.IntNode;14;-1277.251,657.8445;Inherit;False;Property;_Xindex;X index;5;0;Create;True;0;0;0;False;0;False;0;1;False;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;15;-857.6506,1029.103;Inherit;False;Property;_Rows;Rows;3;0;Create;True;0;0;0;False;0;False;4;6;False;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;16;-865.5056,1119.453;Inherit;False;Property;_Columns;Columns;4;0;Create;True;0;0;0;False;0;False;4;4;False;0;1;INT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;18;-539.6013,361.0788;Inherit;False;MaskRes;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;19;-795.4744,432.5805;Inherit;False;Constant;_MaskCutoffs;Mask Cutoffs;2;0;Create;True;0;0;0;False;0;False;0.5,0.75;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;8;-980.6716,953.0856;Inherit;False;18;MaskRes;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-804.8786,37.80136;Inherit;False;10;CardFrontUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;22;-592.0161,174.6915;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NoiseGeneratorNode;25;474.1514,-124.6775;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;670.6979,130.8335;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;28;547.0229,78.93219;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;26;-4.947014,-215.4755;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;29;252.1212,-165.6756;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleTimeNode;30;240.6909,10.35097;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;32;733.0585,271.2281;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;38;615.9534,515.5788;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;23;24.43671,577.9353;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CrossProductOpNode;46;815.4864,1014.064;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;44;677.1936,962.2045;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;42;430.1589,919.8318;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TangentVertexDataNode;45;351.0196,1098.577;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;48;667.9968,1083.211;Inherit;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;49;520.9283,1099.324;Inherit;False;FLOAT4;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;1144.844,719.146;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PiNode;51;698.053,731.5155;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;52;856.378,874.7281;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;180;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;1000.492,1053.235;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;6;-484.2214,829.37;Inherit;False;4;4;0;FLOAT2;0,0;False;1;FLOAT2;-1,-1;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;31;56.22849,10.35095;Inherit;False;Property;_NoiseSpeed;Noise Speed;8;0;Create;True;0;0;0;False;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;528.3639,720.3215;Inherit;False;Property;_curlAmount;curl Amount;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;21;215.3565,216.6165;Inherit;True;Property;_TextureSample1;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-78.85404,-468.3762;Inherit;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;33;-986.6819,-490.2762;Inherit;True;Property;_TarotExtraMaps;Tarot ExtraMaps;3;0;Create;True;0;0;0;False;0;False;-1;None;1792614ad1d9445f18746d2e80c25864;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;54;-116.5544,-457.7404;Inherit;False;2;0;FLOAT;0.1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;55;-682.6882,-631.3409;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;56;-574.2655,-428.3369;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-395.8215,-134.957;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;1;-1082.361,-225.5273;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;0;False;0;False;None;10ace6986e9dc4f89940983db4d40f2c;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;57;-1246.583,-564.7682;Inherit;True;Property;_depthMap;depthMap;2;0;Create;True;0;0;0;False;0;False;None;1792614ad1d9445f18746d2e80c25864;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;24;-966.6972,131.2104;Inherit;False;Property;_parallaxAmount;parallaxAmount;7;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxOcclusionMappingNode;37;-228.6365,161.3376;Inherit;False;1;99;False;;128;False;;4;0.02;0.5;False;1,1;True;0,0;8;0;FLOAT2;0,0;False;1;SAMPLER2D;;False;7;SAMPLERSTATE;;False;2;FLOAT;0.02;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT2;0,0;False;6;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-486.6637,65.13205;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1842.989,277.8911;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;GD/Ghost Image;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;1374.532,390.1194;Inherit;False;35;Alpha;1;0;OBJECT;;False;1;FLOAT;0
WireConnection;7;0;4;0
WireConnection;7;1;8;0
WireConnection;9;0;6;0
WireConnection;9;1;13;0
WireConnection;10;0;9;0
WireConnection;11;0;14;0
WireConnection;11;1;12;0
WireConnection;12;0;5;0
WireConnection;13;0;15;0
WireConnection;13;1;16;0
WireConnection;18;0;19;0
WireConnection;25;0;29;0
WireConnection;27;0;25;0
WireConnection;27;1;21;1
WireConnection;28;0;25;0
WireConnection;28;1;21;1
WireConnection;29;0;26;0
WireConnection;29;1;30;0
WireConnection;30;0;31;0
WireConnection;32;0;21;1
WireConnection;23;0;21;1
WireConnection;46;0;44;0
WireConnection;46;1;48;0
WireConnection;44;0;42;0
WireConnection;48;0;49;0
WireConnection;49;0;45;0
WireConnection;40;0;38;2
WireConnection;40;1;51;0
WireConnection;40;2;44;0
WireConnection;40;3;38;2
WireConnection;40;4;38;2
WireConnection;51;0;41;0
WireConnection;52;0;41;0
WireConnection;50;0;46;0
WireConnection;50;1;45;4
WireConnection;6;0;7;0
WireConnection;6;2;11;0
WireConnection;6;3;13;0
WireConnection;21;0;1;0
WireConnection;21;1;37;0
WireConnection;35;0;2;4
WireConnection;33;0;57;0
WireConnection;33;1;17;0
WireConnection;54;1;33;4
WireConnection;55;0;33;1
WireConnection;55;1;33;2
WireConnection;56;0;55;0
WireConnection;56;1;33;3
WireConnection;2;0;1;0
WireConnection;2;1;17;0
WireConnection;37;0;17;0
WireConnection;37;1;57;0
WireConnection;37;2;34;0
WireConnection;37;3;22;0
WireConnection;34;0;24;0
WireConnection;0;0;21;0
WireConnection;0;9;36;0
WireConnection;0;10;36;0
WireConnection;0;11;40;0
ASEEND*/
//CHKSM=B48B6DE1A729657B8067ACAB2F8C350EDCD64DF0