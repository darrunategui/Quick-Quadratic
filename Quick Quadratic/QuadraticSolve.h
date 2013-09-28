//
//  QuadraticSolve.h
//  Quick Quadratic
//
//  Created by David Arrunategui on 2013-01-26.
//  Copyright (c) 2013 David Arrunategui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuadraticSolve : NSObject

- (NSString *)solveOne:(double)a :(double)b :(double)c;

- (NSString *)solveTwo:(double)a :(double)b :(double)c;

- (int)hasRoots:(double)a :(double)b :(double)c;

- (NSString *)solveVertex:(double)a :(double)b :(double)c;

@end
