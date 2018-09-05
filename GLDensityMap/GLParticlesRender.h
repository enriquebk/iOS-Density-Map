//
//  ParticlesDensityMap.h
//  HMHeatmap
//
//  Created by Enrique Bermúdez on 1/22/18.
//  Copyright © 2018 Enrique Bermúdez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGLDrawable.h>
#import <UIKit/UIKit.h>

/**
 * Used to define the style of the particles.
 */
typedef struct {
    //Points Radius. (Max 128)
    float radius;
    
    //Points blur amount (0.0 - 1.0)
    float blurFactor;
    
    //Points color
    float r; //(0 - 255)
    float g;
    float b;
    float opacity;//(0.0 - 1.0)
    
} GLParticleStyle;

extern const GLParticleStyle GLParticleStyleNone;

@class GLParticlesRender;

typedef uint GLStyleGroupIndex;
typedef uint GLParticleIndex;

@protocol GLParticlesRenderDelegate

@required

/**
 * Called when rendering. Returns the numbers of particles groups.
 */
- (int)styleGroupsCountForRender:(GLParticlesRender *)render;

/**
 * Called when rendering. Returns the style of the group at index `groupIndex`.
 */
- (GLParticleStyle)render:(GLParticlesRender *)render styleForStyleGroup:(GLStyleGroupIndex)groupIndex;

/**
 * Called when rendering. Returns the numbers of particles for group at index `groupIndex`.
 */
- (int)render:(GLParticlesRender *)render particlesCountForGroup:(GLStyleGroupIndex)groupIndex;

/**
 * Called when rendering. Returns the position for particle at index `particlesIndex` for group at index `groupIndex`.
 */
- (CGPoint)render:(GLParticlesRender *)render positionForParticle:(GLParticleIndex)particleIndex
         forStyleGroupIndex:(GLStyleGroupIndex)groupIndex;
@end

/**
 *  Particles render.
 */
@interface GLParticlesRender : NSObject

/**
 * Particles render's delegate.
 */
@property(weak) id<GLParticlesRenderDelegate>delegate;

/**
 * Renders the particles on a EAGLContext.
 */
- (void)drawMapInEAGLContext:(EAGLContext *)context;

@end
