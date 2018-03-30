//
//  GLDensityMapTests.m
//  GLDensityMapTests
//
//  Created by Enrique on 3/19/18.
//  Copyright © 2018 Enrique Bermúdez. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FBSnapshotTestCase.h"
#import "GLDensityMap.h"

@interface GLDensityMapTests : FBSnapshotTestCase

@property NSArray<NSValue *> *groupOne;
@property NSArray<NSValue *> *groupTwo;

@end

@implementation GLDensityMapTests

- (void)setUp {
    [super setUp];
    self.recordMode = NO;
    
    self.groupOne = @[[NSValue valueWithCGPoint: CGPointMake(2, 10)],
                      [NSValue valueWithCGPoint: CGPointMake(32, 40)],
                      [NSValue valueWithCGPoint: CGPointMake(12, 24)],
                      [NSValue valueWithCGPoint: CGPointMake(34, 30)],
                      [NSValue valueWithCGPoint: CGPointMake(14, 26)],
                      [NSValue valueWithCGPoint: CGPointMake(26, 5)],
                      [NSValue valueWithCGPoint: CGPointMake(29, 13)],
                      [NSValue valueWithCGPoint: CGPointMake(23, 9)]];
    
    self.groupTwo = @[[NSValue valueWithCGPoint: CGPointMake(40, 33)],
                      [NSValue valueWithCGPoint: CGPointMake(10, 36)],
                      [NSValue valueWithCGPoint: CGPointMake(26, 14)],
                      [NSValue valueWithCGPoint: CGPointMake(5, 26)],
                      [NSValue valueWithCGPoint: CGPointMake(13, 29)],
                      [NSValue valueWithCGPoint: CGPointMake(9, 23)]];
}

- (void)testNonStyleParticle {
    
    CGSize imageSize = CGSizeMake(50, 50);
    
    GLDensityMapView *densityMapView = [[GLDensityMapView alloc] initWithFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    
     densityMapView.styleForStyleGroup = ^GLParticleStyle(GLStyleGroupIndex groupIndex) {
         return GLParticleStyleNone;
     };
    
     densityMapView.particlesCountForStyleGroup = ^uint(GLStyleGroupIndex groupIndex) {
         return 1;
     };
    
     densityMapView.positionForParticle = ^CGPoint(GLParticleIndex pointIndex, GLStyleGroupIndex groupIndex) {
         return  CGPointMake(imageSize.width/2,imageSize.height/2);
     };
    
    FBSnapshotVerifyView(densityMapView, nil);
}

- (void)testRenderOneGroup{
    
    GLDensityMapView *densityMapView = [[GLDensityMapView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    
    densityMapView.styleForStyleGroup = ^GLParticleStyle(GLStyleGroupIndex groupIndex) {
        GLParticleStyle style = {
            .radius = 7,
            .blurFactor = 0.95,
            .r = 65,
            .g = 130,
            .b = 210,
            .opacity = 0.45,
        };
        return style;
    };
    
    densityMapView.particlesCountForStyleGroup = ^uint(GLStyleGroupIndex groupIndex) {
        return (int)self.groupOne.count;
    };
    
    densityMapView.positionForParticle = ^CGPoint(GLParticleIndex pointIndex, GLStyleGroupIndex groupIndex) {
        NSValue * value = self.groupOne[pointIndex];
        return  value.CGPointValue;
    };
    
    FBSnapshotVerifyView(densityMapView, nil);
}

- (void)testRenderTwoGroups{
    
    GLDensityMapView *densityMapView = [[GLDensityMapView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    
    densityMapView. styleGroupsCount = 2;
    
    densityMapView.styleForStyleGroup = ^GLParticleStyle(GLStyleGroupIndex groupIndex) {
        GLParticleStyle styleGroupOne = {
            .radius = 7,
            .blurFactor = 0.95,
            .r = 65,
            .g = 130,
            .b = 210,
            .opacity = 0.45,
        };
        
        GLParticleStyle styleGroupTwo = {
            .radius = 6,
            .blurFactor = 0.45,
            .r = 255,
            .g = 100,
            .b = 10,
            .opacity = 0.85,
        };
        return (groupIndex == 0 ? styleGroupOne : styleGroupTwo);
    };
    
    densityMapView.particlesCountForStyleGroup = ^uint(GLStyleGroupIndex groupIndex) {
        return (int)(groupIndex == 0 ? self.groupOne.count : self.groupTwo.count);
    };
    
    densityMapView.positionForParticle = ^CGPoint(GLParticleIndex pointIndex, GLStyleGroupIndex groupIndex) {
        NSValue * value = groupIndex == 0 ? self.groupOne[pointIndex] : self.groupTwo[pointIndex];
        return  value.CGPointValue;
    };
    
    FBSnapshotVerifyView(densityMapView, nil);
}

@end
