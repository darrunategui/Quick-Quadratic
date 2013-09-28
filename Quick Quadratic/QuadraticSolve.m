//
//  QuadraticSolve.m
//  Quick Quadratic
//
//  Created by David Arrunategui on 2013-01-26.
//  Copyright (c) 2013 David Arrunategui. All rights reserved.
//

#import "QuadraticSolve.h"

@implementation QuadraticSolve

- (NSString *)solveOne:(double)a :(double)b :(double)c
{
    NSString *result;
    if ([self hasRoots:a :b :c] == 0)
    {
        double discriminant = sqrt((-1)*(pow(b, 2) - 4*a*c));
        double imaginaryTerm = discriminant/(2*a);
        if (imaginaryTerm < 0) {
            imaginaryTerm *= -1;
        }
        
        if (round(imaginaryTerm) != imaginaryTerm)
            result = [NSString stringWithFormat:@"%g + %.3fi", (-b)/(2*a) , imaginaryTerm]; //display 3 decimal places
        else 
            result = [NSString stringWithFormat:@"%g + %gi", (-b)/(2*a) , imaginaryTerm]; //no decimal places necessary
        return result;
    }
    else
    {
        double resultAsDouble = (- b + sqrt(pow(b, 2) - 4*a*c))/(2*a);
        result = [NSString stringWithFormat:@"%g", resultAsDouble];
        return result;
    }
}

- (NSString *)solveTwo:(double)a :(double)b :(double)c
{
    NSString *result;
    if ([self hasRoots:a :b :c] == 0)
    {
        double discriminant = sqrt((-1)*(pow(b, 2) - 4*a*c));
        double imaginaryTerm = discriminant/(2*a);
        if (imaginaryTerm < 0) {
            imaginaryTerm *= -1;
        }
        if (round(imaginaryTerm) != imaginaryTerm)
            result = [NSString stringWithFormat:@"%g - %.3fi", (-b)/(2*a) , imaginaryTerm]; //display 3 decimal places
        else
            result = [NSString stringWithFormat:@"%g - %gi", (-b)/(2*a) , imaginaryTerm]; //no decimal places necessary
        return result;
    }
    else
    {
        double resultAsDouble = (- b - sqrt(pow(b, 2) - 4*a*c))/(2*a);
        NSString *result = [NSString stringWithFormat:@"%g", resultAsDouble];
        return result;
    }
}

- (int)hasRoots:(double)a :(double)b :(double)c
{
    if (pow(b, 2) - 4*a*c > 0) // 2 real roots
        return 2;
    else if (pow(b, 2) - 4*a*c == 0) // only 1 real root
        return 1;
    else
        return 0; // zero real roots (imaginary)
}

- (NSString *)solveVertex:(double)a :(double)b :(double)c
{
    NSString * vertex = nil;
    double x = -b/(2*a);
    double y = a*pow(x, 2) + b*x + c;
    vertex = [NSString stringWithFormat:@"(%.3f, %.3f)", x, y];
    return vertex;
}

@end
