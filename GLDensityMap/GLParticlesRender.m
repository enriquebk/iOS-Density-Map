//
//  ParticlesDensityMap.m
//  HMHeatmap
//
//  Created by Enrique Bermúdez on 1/22/18.
//  Copyright © 2018 Enrique Bermúdez. All rights reserved.
//

#import "GLParticlesRender.h"
#import "GLShaderUtils.h"

const GLParticleStyle GLParticleStyleNone = {
    .radius = 5,
    .blurFactor = 0.5,
    .r = 0,
    .g = 0,
    .b = 0,
    .opacity = 0.5,
};

@interface GLParticlesRender () {
    
    // Vertex Buffer Object
    GLuint vboId;
    
    // Shader objects
    GLuint vertexShader;
    GLuint fragmentShader;
    
    //Shader Program
    GLuint shaderProgramId;
    
    //Vertex buffer it will hold the points locations
    GLfloat* vertexBuffer;
    
    //Number of points that will be displayed
    NSUInteger pointsCount;
}

@end

@implementation GLParticlesRender

- (id)init{
    
    self = [super init];
    
    if (self) {
        
        // Create a Vertex Buffer Object
        glGenBuffers(1, &vboId);
        
        // Load shaders
        shaderProgramId = [GLShaderUtils programFromVertexShaderFile:@"point.vsh" fragmentShaderFile:@"point.fsh" vertexShaderPointer:&vertexShader fragmentShaderPointer:&fragmentShader];
    }
    return self;
}

#pragma mark - Public Methods

- (void)drawMapInEAGLContext:(EAGLContext *)context{

    [EAGLContext setCurrentContext:context];
    
    // Enable blending and set a blending function appropriate for premultiplied alpha pixel data
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    if(self.delegate){
        for (GLStyleGroupIndex gi = 0; gi<[self.delegate styleGroupsCountForRender:self]; gi++) {
            
            pointsCount = [self.delegate render:self particlesCountForGroup:gi];
            
            [self loadVertexBufferForGroup:gi];
            
            [self drawParticlesGroup:gi withStyle: [self.delegate render:self styleForStyleGroup:gi]];
        }
    }
}

#pragma mark - Private Methods

- (void)drawParticlesGroup:(GLStyleGroupIndex)groupIndex withStyle:(GLParticleStyle)style{
    
    //Configure shaders
    
    glUseProgram(shaderProgramId);
    
    GLuint MVPSlot = glGetUniformLocation(shaderProgramId, "MVP");
    GLuint pointSizeSlot = glGetUniformLocation(shaderProgramId, "pointSize");
    GLuint burFactorSlot = glGetUniformLocation(shaderProgramId, "inBlurFactor");
    GLuint vertexColorSlot = glGetUniformLocation(shaderProgramId, "vertexColor");
    
    GLint rWidth;
    GLint rHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &rWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &rHeight);
    
    // viewing matrices
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, rWidth, 0, rHeight, -1, 1);
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    glUniformMatrix4fv(MVPSlot, 1, GL_FALSE, MVPMatrix.m);
    
    // Blur factor
    glUniform1f(burFactorSlot, style.blurFactor);
    
    // point size (max 256)
    glUniform1f(pointSizeSlot, style.radius*2*[[UIScreen mainScreen] scale]);
    
    // color
    GLfloat color[4] = {(style.r/255.0)*style.opacity,
                        (style.g/255.0)*style.opacity,
                        (style.b/255.0)*style.opacity,
                        style.opacity};
    
    glUniform4fv(vertexColorSlot, 1, color);
    
    GLenum err = glGetError();
    if (err != GL_NO_ERROR) {
        printf("[GLDensityMap] glError: %04x caught at %s:%u\n", err, __FILE__, __LINE__);
    }
    
    // Load the vertex buffer to the Vertex Buffer Object
    glBindBuffer(GL_ARRAY_BUFFER, vboId);
    glBufferData(GL_ARRAY_BUFFER, pointsCount*2*sizeof(GLfloat), vertexBuffer, GL_DYNAMIC_DRAW);
    
    GLuint inVertexSlot = glGetAttribLocation(shaderProgramId, "inVertex");
    glEnableVertexAttribArray(inVertexSlot);
    glVertexAttribPointer(inVertexSlot, 2, GL_FLOAT, GL_FALSE, 0, 0);
    
    // Now we can draw the particles
    glDrawArrays(GL_POINTS, 0, (int)pointsCount);
    
    glDisableVertexAttribArray(inVertexSlot);
    glBindBuffer(GL_ARRAY_BUFFER, 0); //Unbind buffer
}

- (void)loadVertexBufferForGroup:(GLStyleGroupIndex)groupIndex{
    
    if(vertexBuffer){
        free(vertexBuffer);
        vertexBuffer = nil;
    }
    
    vertexBuffer = malloc(pointsCount * 2 * sizeof(GLfloat));
    
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    for(int i = 0; i < pointsCount; ++i) {
        
        CGPoint pos = [self.delegate render:self positionForParticle:i forStyleGroupIndex:groupIndex];
        
        //Converts a UIKit point to GL coords.
        vertexBuffer[2 * i + 0] = pos.x*[[UIScreen mainScreen] scale];
        vertexBuffer[2 * i + 1] = backingHeight - pos.y*[[UIScreen mainScreen] scale];
    }
}

#pragma mark -

-(void)dealloc{
    
    if (vboId) {
        glDeleteBuffers(1, &vboId);
        vboId = 0;
    }
    
    if (shaderProgramId) {
        glDeleteProgram(shaderProgramId);
        shaderProgramId = 0;
    }
    
    if (vertexShader) {
        glDeleteShader(vertexShader);
        vertexShader = 0;
    }
    
    if (fragmentShader) {
        glDeleteShader(fragmentShader);
        fragmentShader = 0;
    } 
}

@end
