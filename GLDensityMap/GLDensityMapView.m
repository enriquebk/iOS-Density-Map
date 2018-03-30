//
//  GLDensityMapView.m
//  GLDensityMap
//
//  Created by Enrique on 3/15/18.
//  Copyright © 2018 Enrique. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "GLDensityMapView.h"
#import "CAEAGLLayerCustom.h"

@interface GLDensityMapView()<CAEAGLLayerCustomDelegate>
{
    EAGLContext *context;
    
    // OpenGL names for the renderbuffer and framebuffers used to render to this view
    GLuint viewRenderbuffer, viewFramebuffer;
    
    // Shader objects
    GLuint vertexShader;
    GLuint fragmentShader;
    GLuint shaderProgram;
    
    //On background you should not do GPU operations.
    BOOL canPerformGPUCalls;
}

//Density map
@property(strong)GLParticlesRender *particlesRender;

@end

@implementation GLDensityMapView

// Implement this to override the default layer class (which is [CALayer class]).
// We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
+ (Class)layerClass
{
    return [CAEAGLLayerCustom class];
}

- (id)init{
    if ((self = [super init])) {
        [self initView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])) {
        [self initView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder {
    if ((self = [super initWithCoder:coder])) {
        [self initView];
    }
    return self;
}

- (void)initView{
    
    //Setup properties
    self.styleGroupsCount = 1;
    self.positionForParticle =  ^CGPoint(GLParticleIndex pointIndex, GLStyleGroupIndex groupIndex) {
        return CGPointZero;
    };
    
    self.styleForStyleGroup = ^GLParticleStyle(GLStyleGroupIndex groupIndex) {
        return GLParticleStyleNone;
    };
    
    self.particlesCountForStyleGroup = ^uint(GLStyleGroupIndex groupIndex) {
        return 0;
    };
    
    //Init GL
    [self setupEAGLView];
    [self createBuffers];
    
    canPerformGPUCalls = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.particlesRender = [GLParticlesRender new];
    self.particlesRender.delegate = self;
}

- (void)applicationWillResignActive{
    
    canPerformGPUCalls = NO;
    
    [self destroyBuffers];
}

- (void)applicationDidBecomeActiveNotification{
    canPerformGPUCalls = YES;
}

- (void)setupEAGLView{
    
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    eaglLayer.opaque = YES;
    // In this application, we want to retain the EAGLDrawable contents after a call to presentRenderbuffer.
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!context || ![EAGLContext setCurrentContext:context]) {
        NSLog(@"[GLDensityMap] failed to init GLDensityMapView");
    }
    
    // Set the view's scale factor
    self.contentScaleFactor = [[UIScreen mainScreen] scale];
    
    //Setup as a transparent view
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    self.layer.opaque = NO;
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    const CGFloat myColor[] = {0.0, 0.0, 0.0, 0.0};
    CGColorRef backgroundColor = CGColorCreate(rgb, myColor);
    eaglLayer.backgroundColor = backgroundColor;
    CFRelease(backgroundColor);
    CGColorSpaceRelease(rgb);
    
    ((CAEAGLLayerCustom *)self.layer).layerDelegate = self;
}

- (void)destroyBuffers{
    
    // Destroy framebuffers and renderbuffers
    if (viewFramebuffer) {
        glDeleteFramebuffers(1, &viewFramebuffer);
        viewFramebuffer = 0;
    }
    if (viewRenderbuffer) {
        glDeleteRenderbuffers(1, &viewRenderbuffer);
        viewRenderbuffer = 0;
    }
}

- (void)createBuffers{
    
    // The pixel dimensions
    GLint backingWidth;
    GLint backingHeight;
    
    // Generate IDs for a framebuffer object and a color renderbuffer
    glGenFramebuffers(1, &viewFramebuffer);
    glGenRenderbuffers(1, &viewRenderbuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    // This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
    // allowing us to draw into a buffer that will later be rendered to screen wherever the layer is (which corresponds with our view).
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)self.layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderbuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER,   GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
    
    // Setup the view port in Pixels
    glViewport(0, 0, backingWidth ,backingHeight);
}

#pragma mark - Public methods

- (void)render{
    
    if(canPerformGPUCalls){
        
        [EAGLContext setCurrentContext:context];
        
        if(viewRenderbuffer == 0 || viewFramebuffer == 0){
            [self createBuffers];
        }
        
        //Clear the framebuffer
        glClearColor(0.0, 0.0, 0.0, 0.0);
        glClear(GL_COLOR_BUFFER_BIT);
        
        //Draw desnity map
        [self.particlesRender drawMapInEAGLContext:context];
        
        // Display the buffer
        [context presentRenderbuffer:GL_RENDERBUFFER];
    }
}

#pragma mark - GLDensityMapRenderDelegate

- (int)styleGroupsCountForRender:(GLParticlesRender *)render{
    return self.styleGroupsCount;
}

- (int)render:(GLParticlesRender *)render particlesCountForGroup:(GLStyleGroupIndex)groupIndex{
    return self.particlesCountForStyleGroup(groupIndex);
}

- (CGPoint)render:(GLParticlesRender *)render positionForParticle:(GLParticleIndex)particleIndex
forStyleGroupIndex:(GLStyleGroupIndex)groupIndex{
    return self.positionForParticle(particleIndex,groupIndex);
}

- (GLParticleStyle)render:(GLParticlesRender *)render styleForStyleGroup:(GLStyleGroupIndex)groupIndex{
    return self.styleForStyleGroup(groupIndex);
}

#pragma mark - CAEAGLLayerCustomDelegate methods

- (GLint)framebufferForLayer:(CAEAGLLayerCustom *)layer{
    return viewFramebuffer;
}

- (EAGLContext *)eagleContextForLayer:(CAEAGLLayerCustom *)layer{
    return context;
}

- (float)contentScaleFactorForLayer:(CAEAGLLayerCustom *)layer{
    return self.contentScaleFactor;
}

#pragma mark -

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return NO;
}

-(void)layoutSubviews
{
    [EAGLContext setCurrentContext:context];
    
    [self destroyBuffers];
    [self render];
}

- (void)dealloc
{
    [self destroyBuffers];
    
    // tear down context
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
