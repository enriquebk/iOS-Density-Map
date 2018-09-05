//
//  CAEAGLLayerCustom.h
//  GLDensityMap
//
//  Created by Enrique Bermúdez on 3/29/18.
//  Copyright © 2018 Enrique Bermúdez. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>

@class CAEAGLLayerCustom;

@protocol CAEAGLLayerCustomDelegate

@required

/**
 * Retruns the presenting framebuffer ID.
 */
- (GLint)framebufferForLayer:(CAEAGLLayerCustom *)layer;

/**
 * Retruns the EAGLContext needed to present the framebuffer.
 */
- (EAGLContext *)eagleContextForLayer:(CAEAGLLayerCustom *)layer;

/**
 * Retruns the view's contentScaleFactor required to present the framebuffer.
 */
- (float)contentScaleFactorForLayer:(CAEAGLLayerCustom *)layer;

@end

/**
 * CAEAGLLayerCustom is in charge of presenting the layer framebuffer when `renderInContext:` is called. Otherwise if the framebuffer is not presented the `renderInContext:` will not draw any openGL content.
 */
@interface CAEAGLLayerCustom : CAEAGLLayer

@property(weak) id<CAEAGLLayerCustomDelegate> layerDelegate;

@end
