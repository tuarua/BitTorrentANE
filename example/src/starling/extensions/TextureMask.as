// =================================================================================================
//
//	Starling Framework
//	Copyright 2011-2015 Gamua. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.extensions
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.*;
	import starling.errors.MissingContextError;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.utils.VertexData;
	
	/** An Image-like DisplayObject that discards texels with an alpha value below a certain
	 *  threshold. This makes it perfect for arbitrarily shaped stencil masks.
	 */
	public class TextureMask extends DisplayObject
	{
		private static var PROGRAM_NAME:String = "starling.display.TextureMask";
		
		private var mTexture:Texture;
		private var mVertexData:VertexData;
		private var mVertexBuffer:VertexBuffer3D;
		private var mIndexBuffer:IndexBuffer3D;
		private var mThreshold:Number;
		
		// helper objects (to avoid temporary objects)
		private static var sHelperMatrix:Matrix = new Matrix();
		private static var sThresholdVector:Vector.<Number> = new <Number>[0, 0, 0, 0];
		private static var sRenderAlpha:Vector.<Number> = new <Number>[1, 1, 1, 1];
		
		/** Creates a new TextureMask with given texture. On rendering, any pixel with an alpha
		 *  value below 'threshold' will be discarded. */
		public function TextureMask(texture:Texture, threshold:Number=0.5)
		{
			mTexture = texture;
			mThreshold = threshold;
			
			setupVertices();
			createBuffers();
			registerPrograms();
			
			// Handle lost context. We use the conventional event here (not the one from Starling)
			// so we're able to create a weak event listener; this avoids memory leaks when people
			// forget to call "dispose" on the QuadBatch.
			Starling.current.stage3D.addEventListener(Event.CONTEXT3D_CREATE,
				onContextCreated, false, 0, true);
		}
		
		/** Disposes all resources of the display object. Beware that the texture needs to be
		 *  disposed manually (after all, it might be in use somewhere else). */
		public override function dispose():void
		{
			Starling.current.stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			
			if (mVertexBuffer) mVertexBuffer.dispose();
			if (mIndexBuffer)  mIndexBuffer.dispose();
			
			super.dispose();
		}
		
		private function onContextCreated(event:Object):void
		{
			createBuffers();
			registerPrograms();
		}
		
		/** Initializes the vertex positions and texture coordinates. */
		private function setupVertices():void
		{
			var frame:Rectangle = mTexture.frame;
			var width:Number  = frame ? frame.width  : mTexture.width;
			var height:Number = frame ? frame.height : mTexture.height;
			
			if (mVertexData == null)
				mVertexData = new VertexData(4);
			
			mVertexData.setPremultipliedAlpha(mTexture.premultipliedAlpha, false);
			mVertexData.setPosition(0, 0.0, 0.0);
			mVertexData.setPosition(1, width, 0.0);
			mVertexData.setPosition(2, 0.0, height);
			mVertexData.setPosition(3, width, height);
			mVertexData.setTexCoords(0, 0.0, 0.0);
			mVertexData.setTexCoords(1, 1.0, 0.0);
			mVertexData.setTexCoords(2, 0.0, 1.0);
			mVertexData.setTexCoords(3, 1.0, 1.0);
			
			mTexture.adjustVertexData(mVertexData, 0, 4);
		}
		
		/** Creates vertex- and index-buffers. */
		private function createBuffers():void
		{
			var context:Context3D = Starling.context;
			if (context == null) throw new MissingContextError();
			
			if (mVertexBuffer) mVertexBuffer.dispose();
			if (mIndexBuffer)  mIndexBuffer.dispose();
			
			mVertexBuffer = context.createVertexBuffer(mVertexData.numVertices, VertexData.ELEMENTS_PER_VERTEX);
			mVertexBuffer.uploadFromVector(mVertexData.rawData, 0, mVertexData.numVertices);
			
			var indexData:Vector.<uint> = new <uint>[0, 1, 2, 1, 3, 2];
			
			mIndexBuffer = context.createIndexBuffer(indexData.length);
			mIndexBuffer.uploadFromVector(indexData, 0, indexData.length);
		}
		
		/** Creates vertex and fragment programs from assembly. */
		private function registerPrograms():void
		{
			var target:Starling = Starling.current;
			if (target.hasProgram(PROGRAM_NAME)) return; // already registered
			
			// va0 -> position
			// va1 -> texture coordinates
			// vc0 -> alpha
			// vc1 -> mvpMatrix (4 vectors, vc1 - vc4)
			
			var vertexShader:String =
				"m44 op, va0, vc1 \n" + // 4x4 matrix transform to output space
				"mov v0, va1      \n" + // pass texture coordinates to fragment program
				"mov v1, vc0      \n";  // pass alpha to fragment program
			
			var fragmentShader:String =
				"tex ft1,  v0, fs0 <???> \n" + // sample texture 0
				"sub ft2, ft1, fc0       \n" + // subtract threshold
				"kil ft2.w               \n" + // abort if alpha below 0
				"mul  oc,  v1, ft1       \n";  // else multiply with alpha & copy to output buffer
			
			fragmentShader = fragmentShader.replace("<???>",
				RenderSupport.getTextureLookupFlags(mTexture.format, mTexture.mipMapping,
					mTexture.repeat));
			
			target.registerProgramFromSource(PROGRAM_NAME, vertexShader, fragmentShader);
		}
		
		/** @inheritDoc */
		public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
		{
			if (resultRect == null) resultRect = new Rectangle();
			
			var transformationMatrix:Matrix = targetSpace == this ?
				null : getTransformationMatrix(targetSpace, sHelperMatrix);
			
			return mVertexData.getBounds(transformationMatrix, 0, -1, resultRect);
		}
		
		/** @inheritDoc */
		public override function render(support:RenderSupport, parentAlpha:Number):void
		{
			var context:Context3D = Starling.context;
			if (context == null) throw new MissingContextError();
			
			var pma:Boolean = mVertexData.premultipliedAlpha;
			var alpha:Number = this.alpha * parentAlpha;
			
			support.finishQuadBatch();
			support.raiseDrawCount();
			support.applyBlendMode(pma);
			
			sThresholdVector[3] = mThreshold;
			sRenderAlpha[0] = sRenderAlpha[1] = sRenderAlpha[2] = pma ? alpha : 1.0;
			sRenderAlpha[3] = alpha;
			
			context.setTextureAt(0, mTexture.base);
			context.setProgram(Starling.current.getProgram(PROGRAM_NAME));
			context.setVertexBufferAt(0, mVertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			context.setVertexBufferAt(1, mVertexBuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, sRenderAlpha, 1);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, support.mvpMatrix3D, true);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, sThresholdVector, 1);
			
			context.drawTriangles(mIndexBuffer, 0, 2);
			
			context.setTextureAt(0, null);
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
		}
		
		/** The texture that is currently in use. */
		public function get texture():Texture { return mTexture; }
		public function set texture(value:Texture):void
		{
			mTexture = value;
			
			setupVertices();
			createBuffers();
		}
		
		/** Any pixel with an alpha value below 'threshold' will be discarded. */
		public function get threshold():Number { return mThreshold; }
		public function set threshold(value:Number):void { mThreshold = value; }
	}
}