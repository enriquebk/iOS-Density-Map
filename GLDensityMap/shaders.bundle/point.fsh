

varying lowp vec4 color;
varying lowp float blurFactor;

void main()
{
    //In order to apply the blur factor we need to make the pixel more transparent depending the distance from the center (0.5, 0.5).

    lowp float dx = vec2(gl_PointCoord).x - 0.5;
    lowp float dy = vec2(gl_PointCoord).y - 0.5;
    lowp float dist = sqrt(dx*dx + dy*dy);
    
    //We will calculate the opacityfactor that must be applied to this pixel.
    //To do that we will use the pixel distance from center in persetage and the blur factor complement.
    lowp float opacityfactor = 0.0;
    
    //The distance persentage tell us how far (in persentage from 0.0 to 1.0) is the pixel from the center point .
    //Then we juste need to multiply the distance by two, becasue the max distance is 0.5...
    lowp float distPersetage = dist*2.0;

    lowp float blurFactorComplement = 1.0 - blurFactor;
    
    //Now will calculate the opacityfactor.
    //This pixel needs to be opacated?
    if (distPersetage > blurFactorComplement ) {
        
        //Yes, so we calculate the amount of opacity that must be applied
        opacityfactor = 1.0 - (distPersetage -  blurFactorComplement)/abs(1.0 - blurFactorComplement);
    } else {
        
        //No.
        opacityfactor = 1.0;
    }
 
    //Apply the opacityfactor to the pixel. Opacity factor must be between 0 - 1
    gl_FragColor = color*min(1.0,max(0.0,opacityfactor));
}
