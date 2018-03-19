

attribute vec4 inVertex;

uniform mat4 MVP;
uniform float pointSize;
uniform lowp float inBlurFactor;
uniform lowp vec4 vertexColor;

varying lowp vec4 color;
varying lowp float blurFactor;

void main()
{
	gl_Position = MVP * inVertex;
    gl_PointSize = pointSize;
    
    color = vertexColor;
    blurFactor = inBlurFactor;
}
