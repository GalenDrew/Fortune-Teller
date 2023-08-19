// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>
#if UNITY_POST_PROCESSING_STACK_V2
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess( typeof( GDScreenMirrorPPSRenderer ), PostProcessEvent.AfterStack, "GDScreenMirror", true )]
public sealed class GDScreenMirrorPPSSettings : PostProcessEffectSettings
{
}

public sealed class GDScreenMirrorPPSRenderer : PostProcessEffectRenderer<GDScreenMirrorPPSSettings>
{
	public override void Render( PostProcessRenderContext context )
	{
		var sheet = context.propertySheets.Get( Shader.Find( "GD/ScreenMirror" ) );
		context.command.BlitFullscreenTriangle( context.source, context.destination, sheet, 0 );
	}
}
#endif
