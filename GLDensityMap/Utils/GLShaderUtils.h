//
//  GLShaderUtils.h
//  Veyron
//
//  Created by Enrique Bermúdez on 6/1/16.
//  Copyright © 2016 Enrique Bermúdez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GLShaderUtils : NSObject

/**
 * Compile and links a vertex shader file and a fragment shader file. The method retruns
 * the shader program. The vertex and fragment shader pointers will contain the shader objects.
 * Files should be located in the main bundle.
 */
+ (GLuint)programFromVertexShaderFile:(NSString *)vertexShaderfilename
                   fragmentShaderFile:(NSString *)fragmentShaderfilename
                  vertexShaderPointer:(GLuint *)vertexShader
                fragmentShaderPointer:(GLuint *)fragmentShader;

@end
