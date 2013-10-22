//
//  iPadNumberPad.h
//  Quick Quadratic
//
//  Created by David Arrunategui on 2013-10-20.
//  Copyright (c) 2013 David Arrunategui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iPadNumberPad : UIViewController

// The one and only Numberpad instance you should ever need:
+ (iPadNumberPad *)defaultNumberPad;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *keysView;

@end
