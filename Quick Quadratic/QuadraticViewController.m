//
//  QuadraticViewController.m
//  Quick Quadratic
//
//  Created by David Arrunategui on 2013-09-27.
//  Copyright (c) 2013 David Arrunategui. All rights reserved.
//

#import "QuadraticViewController.h"
#import "QuadraticSolve.h"
#import "NumberPad.h"
#import "iPadNumberPad.h"

@interface QuadraticViewController ()

@property (nonatomic, strong) QuadraticSolve *quadratic;
@property (nonatomic) BOOL bannerIsVisible;
@property (nonatomic) CGPoint scrollPosition;

@end

@implementation QuadraticViewController

@synthesize iPhoneScroller = _iPhoneScroller;

- (QuadraticSolve *)quadratic
{
    if (!_quadratic)
        _quadratic = [[QuadraticSolve alloc] init];
    return _quadratic;
}

#pragma mark - keyboard/text input handling

/* Disable the solve button if there are text fields without any input values  */
- (IBAction)keystrokePressed:(UITextField *)sender
{
    BOOL textFieldHasNoInput = self.aValue.text.length==0 || self.bValue.text.length==0 || self.cValue.text.length==0; // if length is 0, there is not input
    BOOL isNotQuadratic = [self.aValue.text doubleValue] == 0; // if the aValue is 0, it is not quadratic
    
    if (textFieldHasNoInput || isNotQuadratic)
        self.solveButton.enabled = NO;
    else
        self.solveButton.enabled = YES;
}

/* hide the solutions area until the solve button is pressed */
- (IBAction)editingDidBegin:(UITextField *)sender
{
    [self changeSolutionsAlphaTo:0.0];
}

/* check if the inputed character is appropriate to be input */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    /* Save the stringWithPendingStringAdded to check if it is valid */
    NSString *stringWithPendingStringAdded = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    /* regular expression will check the correctness of the input format */
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\-?\\d*\\.?\\d*$" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:stringWithPendingStringAdded options:0 range:NSMakeRange(0, stringWithPendingStringAdded.length)];
    
    /* matches[0] should match the entire string starting at */
    /* position 0 if the format of the input is correct */
    BOOL correctFormat = NO;
    if ([matches[0] range].length == stringWithPendingStringAdded.length && [matches[0] range].location == 0)
        correctFormat = YES;
    
    /* check for unnecessary leading Zeros */
    BOOL containsUnnecessaryZeros = NO;
    if ([stringWithPendingStringAdded hasPrefix:@"00"] || [stringWithPendingStringAdded hasPrefix:@"-00"])
        containsUnnecessaryZeros = YES;
    
    /* Limit the number of characters that can be input */
    NSUInteger newLength = stringWithPendingStringAdded.length;
    
    /* Limit the iPad text fields to 40 characters plus a negative sign if added*/
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && newLength > 40 && ![string hasPrefix:@"-"])
        return NO;
    
    /* Limit the iPhone text fields to 20 characters plus a negative sign if added*/
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && newLength > 20 && ![string hasPrefix:@"-"])
        return NO;
    
    /* check all other constraints */
    if (containsUnnecessaryZeros || !correctFormat)
        return NO;
    
    return YES;
}

/* change the image of the selected text field to show it is active*/
- (BOOL)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.aValue.isFirstResponder)
        self.aValueBackView.alpha = 0.95;
    else if (self.bValue.isFirstResponder)
        self.bValueBackView.alpha = 0.95;
    else
        self.cValueBackView.alpha = 0.95;
    return YES;
}

/* return the image of the deselected text field to show it is inactive */
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.aValue.isFirstResponder)
        self.aValueBackView.alpha = 1.0;
    else if (self.bValue.isFirstResponder)
        self.bValueBackView.alpha = 1.0;
    else
        self.cValueBackView.alpha = 1.0;
    return YES;
}

/* When a text field is swiped, clear the text and give it focus (for convenience) */
- (IBAction)handleSwipeGesture:(UISwipeGestureRecognizer *)sender
{
    UITextField *swipedView = (UITextField *)sender.view; // get a reference to the swiped view
    swipedView.text = @""; // clear the text
    self.solveButton.enabled = NO; // disable the solve button since one of the fields is now empty
    [swipedView becomeFirstResponder]; // make the swiped TextField the first responder
}

#pragma mark - solve

/* solve the quadratic equation and show the solution */
- (IBAction)solve:(UIButton *)sender
{
    [self clearSolutions]; // clears the solutions text
    
    double a = [self.aValue.text doubleValue];
    double b = [self.bValue.text doubleValue];
    double c = [self.cValue.text doubleValue];
    
    /* input error checking */
    BOOL inputHasError = NO;
    if (a == 0 || [self.aValue.text isEqualToString:@"-"]) {
        self.solutionOneTitle.text = @"A is not a valid number";
        [self resetScrollViewContentOffset];
        inputHasError = YES;
    }
    else if ([self.bValue.text isEqualToString:@"-"]) {
        self.solutionOneTitle.text = @"B is not a valid number";
        [self resetScrollViewContentOffset];
        inputHasError = YES;
    }
    else if ([self.cValue.text isEqualToString:@"-"]) {
        self.solutionOneTitle.text = @"C is not a valid number";
        [self resetScrollViewContentOffset];
        inputHasError = YES;
    }
    
    if (!inputHasError) {
        /* 2 real solutions */
        if ([self.quadratic hasRoots:a :b :c] == 2)
        {
            self.solutionOneTitle.text = @"Real Root";
            self.solutionOne.text = [self.quadratic solveOne:a :b :c];
            self.solutionTwoTitle.text = @"Real Root";
            self.solutionTwo.text = [self.quadratic solveTwo:a :b :c];
        }
        /* only 1 real solution */
        else if ([self.quadratic hasRoots:a :b :c] == 1)
        {
            self.solutionOneTitle.text = @"Real Root";
            self.solutionOne.text = [self.quadratic solveOne:a :b :c];
            self.solutionTwoTitle.text = @"";
            self.solutionTwo.text = @"";
        }
        /* 2 complex solutions */
        else
        {
            self.solutionOneTitle.text = @"Complex Root";
            self.solutionOne.text = [self.quadratic solveOne:a :b :c];
            self.solutionTwoTitle.text = @"Complex Root";
            self.solutionTwo.text = [self.quadratic solveTwo:a :b :c];
        }
        /* Set the Quadratic Equation Values in the scroll view */
        self.minusBLabel.text = [NSString stringWithFormat:@"%g", (-1)*b];
        self.discriminentLabel.text = [NSString stringWithFormat:@"%g", pow(b, 2) - 4*a*c];
        self.twoALabel.text = [NSString stringWithFormat:@"%g", 2*a];
        /* Set the Vertex and Y-Intercept values in the scroll view */
        self.vertex.text = [self.quadratic solveVertex:a :b :c];
        self.yIntercept.text = self.cValue.text;
    }
    
    if (inputHasError)
    {
        /* only show the error message in the answers */
        [UIView animateWithDuration:0.2 animations:^{
            self.rootsBackgroundImage.alpha = 1.0;
            self.solutionOneTitle.alpha = 1.0;
            self.pageControl.alpha = 1.0;
        }];
    }
    else
    {
        /* fade all solutions into view */
        [self changeSolutionsAlphaTo:1.0];
    }
    [self.view endEditing:YES]; // hide the keyboard
}

#pragma mark - ad banner implementation

/* When a new banner ad was successfully loaded, show the add */
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self.bannerIsVisible) {
        [UIView beginAnimations:@"animatedAdBannerOn" context:NULL];
        self.adBanner.frame = CGRectOffset(self.adBanner.frame, 0, -self.adBanner.frame.size.height);
        [UIView commitAnimations];
        self.bannerIsVisible = YES;
    }
}

/* When a banner add failed to load hide the ad banner */
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // Assumes the banner view is placed at the bottom of the screen.
        self.adBanner.frame = CGRectOffset(self.adBanner.frame, 0, self.adBanner.frame.size.height);
        [UIView commitAnimations];
        self.bannerIsVisible = NO;
    }
}

/* Save the scroller position before the view disappears because the scrollview's content offset will be reset automatically */
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UIScrollView *scrollView = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        scrollView = self.iPadScroller;
    else
        scrollView = self.iPhoneScroller;
    
    self.scrollPosition = scrollView.contentOffset;
}
/* Gets called after the view lays out its subviews */
/* When a user finishes viewing an ad */
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    // only reshow the ad if a banner is successfully loaded
    if (self.adBanner.bannerLoaded)
    {
        self.adBanner.frame = CGRectOffset(self.adBanner.frame, 0, -self.adBanner.frame.size.height);
        self.bannerIsVisible = YES;
    }
    
    // Set the content size of the respective scroll views
    // We need to reset the content size whenever subviews get layed out
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.iPadScroller setContentSize:CGSizeMake(384*3, self.iPadScroller.frame.size.height)];
        self.iPadScroller.contentOffset = self.scrollPosition;
    }
    else
    {
        [self.iPhoneScroller setContentSize:CGSizeMake( [[UIScreen mainScreen] bounds].size.width*3, self.iPhoneScroller.frame.size.height)];
        self.iPhoneScroller.contentOffset = self.scrollPosition;
    }
}

#pragma mark - Scroll View page handling

/* Change the PageControl's current page when the scroll view is scrolled */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger newPage = lroundf(fractionalPage);
    self.pageControl.currentPage = newPage;
}

/* scroll the scrollView programatically when the PageControl is pressed */
- (IBAction)pageControlPressed:(UIPageControl *)sender {
    CGFloat newpage = sender.currentPage*self.iPhoneScroller.frame.size.width;
    [self.iPhoneScroller setContentOffset:CGPointMake(newpage, 0) animated:YES];
}

- (IBAction)textFieldSwiped:(UISwipeGestureRecognizer *)sender
{
    UITextField *swipedView = (UITextField *)sender.view; // get a reference to the swiped view
    swipedView.text = @""; // clear the text
    self.solveButton.enabled = NO; // disable the solve button since one of the fields is now empty
    [swipedView becomeFirstResponder]; // make the swiped TextField the first responder

}


#pragma mark - view handling

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.solutionOne.adjustsFontSizeToFitWidth = YES;
    self.solutionTwo.adjustsFontSizeToFitWidth = YES;
    self.aValue.adjustsFontSizeToFitWidth = YES;
    self.bValue.adjustsFontSizeToFitWidth = YES;
    self.cValue.adjustsFontSizeToFitWidth = YES;
    
    self.minusBLabel.adjustsFontSizeToFitWidth = YES;
    self.discriminentLabel.adjustsFontSizeToFitWidth = YES;
    self.twoALabel.adjustsFontSizeToFitWidth = YES;
    self.vertex.adjustsFontSizeToFitWidth = YES;
    self.yIntercept.adjustsFontSizeToFitWidth = YES;
    
    /* use the correct NumberPad */
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.aValue.inputView = [iPadNumberPad defaultNumberPad].view;
        self.bValue.inputView = [iPadNumberPad defaultNumberPad].view;
        self.cValue.inputView = [iPadNumberPad defaultNumberPad].view;
    }
    else
    {
        self.aValue.inputView = [NumberPad defaultNumberPad].view;
        self.bValue.inputView = [NumberPad defaultNumberPad].view;
        self.cValue.inputView = [NumberPad defaultNumberPad].view;
    }
    /* solve buttons should be disabled at first */
    self.solveButton.enabled = NO;
    
}

- (void)viewDidUnload
{
    [self setAdBanner:nil];
    [self setIPhoneScroller:nil];
    [self setMinusBLabel:nil];
    [self setDiscriminentLabel:nil];
    [self setTwoALabel:nil];
    [self setEquationBackgroundImage:nil];
    [self setEquationTitle:nil];
    [self setPageControl:nil];
    [self setVertexAndInterceptBackgroundImage:nil];
    [self setVertexTitle:nil];
    [self setVertex:nil];
    [self setYInterceptTitle:nil];
    [self setYIntercept:nil];
    [super viewDidUnload];
}

#pragma mark - helper functions

- (void)clearSolutions
{
    self.solutionOneTitle.text = @"";
    self.solutionOne.text = @"";
    self.solutionTwoTitle.text = @"";
    self.solutionTwo.text = @"";
    self.minusBLabel.text = @"";
    self.discriminentLabel.text= @"";
    self.twoALabel.text = @"";
    self.vertex.text = @"";
    self.yIntercept.text = @"";
}

- (void)changeSolutionsAlphaTo:(CGFloat)alphaValue
{
    [UIView animateWithDuration:0.3 animations:^{
        self.rootsBackgroundImage.alpha = alphaValue;
        self.solutionOneTitle.alpha = alphaValue;
        self.solutionOne.alpha = alphaValue;
        self.solutionTwoTitle.alpha = alphaValue;
        self.solutionTwo.alpha = alphaValue;
        self.equationBackgroundImage.alpha = alphaValue;
        self.equationTitle.alpha = alphaValue;
        self.minusBLabel.alpha = alphaValue;
        self.discriminentLabel.alpha = alphaValue;
        self.twoALabel.alpha = alphaValue;
        self.pageControl.alpha = alphaValue;
        self.vertexAndInterceptBackgroundImage.alpha = alphaValue;
        self.vertexTitle.alpha = alphaValue;
        self.vertex.alpha = alphaValue;
        self.yInterceptTitle.alpha = alphaValue;
        self.yIntercept.alpha = alphaValue;
    }];
}

/* sets the scroll view content offset to zero when there is an error in the input */
- (void)resetScrollViewContentOffset
{
    UIScrollView *scrollView = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        scrollView = self.iPadScroller;
    }
    else
    {
        scrollView = self.iPadScroller;
    }
    
    scrollView.contentOffset = CGPointZero;
    self.pageControl.currentPage = 0;
}

- (void)didReceiveMemoryWarning
{
    _aValue = nil;
    _bValue = nil;
    _cValue = nil;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
