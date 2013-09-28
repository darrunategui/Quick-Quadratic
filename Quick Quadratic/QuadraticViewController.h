//
//  QuadraticViewController.h
//  Quick Quadratic
//
//  Created by David Arrunategui on 2013-09-27.
//  Copyright (c) 2013 David Arrunategui. All rights reserved.
//

#import <UIKit/UIKit.h>
@import iAd;

@interface QuadraticViewController : UIViewController <ADBannerViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *aValue;
@property (weak, nonatomic) IBOutlet UITextField *bValue;
@property (weak, nonatomic) IBOutlet UITextField *cValue;

@property (weak, nonatomic) IBOutlet UIButton *solveButton;

@property (weak, nonatomic) IBOutlet UIImageView *rootsBackgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *solutionOneTitle;
@property (weak, nonatomic) IBOutlet UILabel *solutionOne;
@property (weak, nonatomic) IBOutlet UILabel *solutionTwoTitle;
@property (weak, nonatomic) IBOutlet UILabel *solutionTwo;

@property (weak, nonatomic) IBOutlet UIImageView *equationBackgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *minusBLabel;
@property (weak, nonatomic) IBOutlet UILabel *discriminentLabel;
@property (weak, nonatomic) IBOutlet UILabel *twoALabel;
@property (weak, nonatomic) IBOutlet UILabel *equationTitle;

@property (weak, nonatomic) IBOutlet UIImageView *vertexAndInterceptBackgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *vertexTitle;
@property (weak, nonatomic) IBOutlet UILabel *vertex;
@property (weak, nonatomic) IBOutlet UILabel *yInterceptTitle;
@property (weak, nonatomic) IBOutlet UILabel *yIntercept;

@property (weak, nonatomic) IBOutlet UIView *aValueBackView;
@property (weak, nonatomic) IBOutlet UIView *bValueBackView;
@property (weak, nonatomic) IBOutlet UIView *cValueBackView;

@property (strong, nonatomic) IBOutlet ADBannerView *adBanner;

@property (weak, nonatomic) IBOutlet UIScrollView *scroller;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;






@end
