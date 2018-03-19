//
//  GLFrameBufferSnapShot.h
//  GLDensityMap
//
//  Created by Enrique on 3/18/18.
//  Copyright © 2018 Enrique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>

@interface GLFrameBufferSnapshot : NSObject

/**
 * Takes a snapshot of the given framebuffer.
 */
+ (UIImage *)snapshotFromFramebuffer:(GLint)framebuffer
                        eagleContext:(EAGLContext*)contex
                  contentScaleFactor:(float)contentScaleFactor;

@end
