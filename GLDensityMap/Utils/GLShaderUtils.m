//
//  GLShaderUtils.m
//  Veyron
//
//  Created by Enrique on 6/1/16.
//  Copyright © 2016 CodigoDelSur. All rights reserved.
//

#import "GLShaderUtils.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <GLKit/GLKit.h>


@implementation GLShaderUtils

/**
 * Compiles a shader. This methods recives the source of the shader and the type of shader (GL_VERTEX_SHADER, GL_FRAGMENT_SHADER).
 * It returns the shader id.
 */
+ (GLuint)compileShaderSource:(NSString*)source withType:(GLenum)shaderType {
    
    NSString* shaderString = source;
    
    // Calls glCreateShader to create a OpenGL object to represent the shader. When you call this function you need to pass in a shaderType to indicate whether it’s a fragment or vertex shader. We take ethis as a parameter to this method.
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // Calls glShaderSource to give OpenGL the source code for this shader. We do some conversion here to convert the source code from an NSString to a C-string.
    const char * shaderStringUTF8 = [shaderString UTF8String];
    GLint shaderStringLength = (GLint)[shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shaderHandle);//compile the shader at runtime!
    
    // This can fail – and it will in practice if your GLSL code has errors in it. When it does fail, it’s useful to get some output messages in terms of what went wrong. This code uses glGetShaderiv and glGetShaderInfoLog to output any error messages to the screen (and quit so you can fix the bug!)
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"[GLDensityMap] Error: %@", messageString);
        glDeleteShader(shaderHandle);
    }
    
    return shaderHandle;
}

/**
 * Given a vertex shader id and a fragment shafer id this method links those two programs and returns the program id.
 */
+ (GLuint)linkVertexShader:(GLuint)vertexShader fragmentShader:(GLuint)fragmentShader{
    
    // Calls glCreateProgram, glAttachShader, and glLinkProgram to link the vertex and fragment shaders into a complete program.
    GLuint shaderProgramId = glCreateProgram();
    glAttachShader(shaderProgramId, vertexShader);
    glAttachShader(shaderProgramId, fragmentShader);
    
    //Link the 2 shaders
    glLinkProgram(shaderProgramId);
    
    // Calls glGetProgramiv and glGetProgramInfoLog to check and see if there were any link errors, and display the output and quit if so.
    GLint linkSuccess;
    glGetProgramiv(shaderProgramId, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(shaderProgramId, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"[GLDensityMap] Program ERROR: %@", messageString);
        glDeleteShader(shaderProgramId);
    }
    
    return shaderProgramId;
}

+ (GLuint)programFromVertexShaderFile:(NSString *)vertexShaderfilename
                 fragmentShaderFile:(NSString *)fragmentShaderfilename
                vertexShaderPointer:(GLuint *)vertexShader
              fragmentShaderPointer:(GLuint *)fragmentShader;
{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"shaders" ofType:@"bundle"]];
    
    NSString *vsrcPath = [bundle pathForResource:[[vertexShaderfilename lastPathComponent] stringByDeletingPathExtension] ofType:[vertexShaderfilename pathExtension]];
    NSError  *vsrcPathError;
    NSString *vsrcString = [NSString stringWithContentsOfFile:vsrcPath
                                                     encoding:NSUTF8StringEncoding error:&vsrcPathError];
    NSError  *fsrcPathError;
    NSString *fsrcPath = [bundle  pathForResource:[[fragmentShaderfilename lastPathComponent] stringByDeletingPathExtension] ofType:[fragmentShaderfilename pathExtension]];
    
    NSString *fsrcString = [NSString stringWithContentsOfFile:fsrcPath
                                                     encoding:NSUTF8StringEncoding error:&fsrcPathError];
    
    *vertexShader = [GLShaderUtils compileShaderSource:vsrcString withType:GL_VERTEX_SHADER];
    
    *fragmentShader = [GLShaderUtils compileShaderSource:fsrcString withType:GL_FRAGMENT_SHADER];
    
    return [GLShaderUtils linkVertexShader:*vertexShader fragmentShader:*fragmentShader];
}

@end
