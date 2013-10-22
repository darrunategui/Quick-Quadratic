//
//  iPadNumberPad.m
//  Quick Quadratic
//
//  Created by David Arrunategui on 2013-10-20.
//  Copyright (c) 2013 David Arrunategui. All rights reserved.
//

#import "iPadNumberPad.h"

const int iPadNumberPadShrinkSize = 15;

#pragma mark - private methods

@interface iPadNumberPad ()
{
    NSTimer *timer;
    UIView *KeyboardBackgroundView;
}

@property (nonatomic, weak) id<UITextInput> targetTextInput;

@end

#pragma mark - iPadNumberpad Implementation

@implementation iPadNumberPad

@synthesize targetTextInput;

#pragma mark - Shared Numberpad method

/* makes sure that NumberPad is a singleton */
+ (iPadNumberPad *)defaultNumberPad
{
    static iPadNumberPad *defaultNumberPad = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultNumberPad = [[iPadNumberPad alloc] init];
    });
    return defaultNumberPad;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor clearColor];
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.keysView.backgroundColor = [UIColor clearColor];
        
        // Add a UIView with a black color to give the background a darker shade.
        KeyboardBackgroundView = [[UIView alloc] initWithFrame:self.view.frame];
        KeyboardBackgroundView.backgroundColor = [UIColor blackColor];
        KeyboardBackgroundView.alpha = 0.7;
        
        // Add the UIToolbar to the main view.
        [self.view insertSubview:KeyboardBackgroundView atIndex:0];
        
    }
    return self;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Keep track of the textView/Field that we are editing
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingDidBegin:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingDidBegin:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingDidEnd:) name:UITextFieldTextDidEndEditingNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingDidEnd:) name:UITextViewTextDidEndEditingNotification object:nil];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidEndEditingNotification object:nil];
    
    self.targetTextInput = nil;
    
    [super viewDidUnload];
}

#pragma mark - editingDidBegin/End

// Editing just began, store a reference to the object that just became the firstResponder
- (void)editingDidBegin:(NSNotification *)notification
{
    if (![notification.object conformsToProtocol:@protocol(UITextInput)]) {
        self.targetTextInput = nil;
        return;
    }
    
    self.targetTextInput = notification.object;
}

// Editing just ended.
- (void)editingDidEnd:(NSNotification *)notification
{
    self.targetTextInput = nil;
}

#pragma mark - Keypad Button Shrinking + Growing

- (IBAction)buttonPressedUp:(UIButton *)sender
{
    NSString * buttonTitle = sender.titleLabel.text;
    float duration = 0.1;
    if ([buttonTitle  isEqual: @"⬅"])
    {
        duration = 0.05;
    }
    [UIView animateWithDuration:duration animations:^{
        sender.titleLabel.text = @"";
        [sender setBounds:CGRectMake(0, 0, sender.bounds.size.width + iPadNumberPadShrinkSize, sender.bounds.size.height + iPadNumberPadShrinkSize)];
        sender.titleLabel.text = buttonTitle;
        sender.alpha = 1;
    }];
    [sender removeTarget:nil action:NULL forControlEvents:UIControlEventTouchDragExit];
    [sender addTarget:nil action:@selector(buttonPressedDown:) forControlEvents:UIControlEventTouchDragEnter];
}
- (IBAction)buttonPressedDown:(UIButton *)sender {
    NSString * buttonTitle = sender.titleLabel.text;
    float duration = 0.1;
    if ([buttonTitle  isEqual: @"⬅"])
    {
        duration = 0.05;
    }
    [UIView animateWithDuration:duration animations:^{
        sender.titleLabel.text = @"";
        [sender setBounds:CGRectMake(0, 0, sender.bounds.size.width - iPadNumberPadShrinkSize, sender.bounds.size.height - iPadNumberPadShrinkSize)];
        sender.titleLabel.text = buttonTitle;
        sender.alpha = 0.9;
    }];
    [sender addTarget:nil action:@selector(buttonPressedUp:) forControlEvents:UIControlEventTouchDragExit];
    [sender removeTarget:nil action:NULL forControlEvents:UIControlEventTouchDragEnter];
}


#pragma mark - Keypad IBAction's

// A number (0-9) was just pressed on the number pad
// Note that this would work just as well with letters or any other character and is not limited to numbers.
- (IBAction)numberPadDigitPressed:(UIButton *)sender
{
    if (!self.targetTextInput) {
        return;
    }
    
    NSString *numberPressed  = sender.titleLabel.text;
    if ([numberPressed length] == 0) {
        return;
    }
    
    UITextRange *selectedTextRange = self.targetTextInput.selectedTextRange;
    if (!selectedTextRange) {
        return;
    }
    
    BOOL positionIsAtStart = [selectedTextRange.start isEqual:[self.targetTextInput positionFromPosition:self.targetTextInput.beginningOfDocument offset:0]];
    
    BOOL textStartsWithMinusAndCaretIsAtOne = [((UITextView *)self.targetTextInput).text hasPrefix:@"-"] && [selectedTextRange.start isEqual:[self.targetTextInput positionFromPosition:self.targetTextInput.beginningOfDocument offset:1]];
    // This check inputs '0.' instead of just '.' in the appropriate places -  This is strictly just for aesthetic pleasure
    if ([numberPressed isEqualToString:@"."] && (positionIsAtStart || textStartsWithMinusAndCaretIsAtOne)) {
        numberPressed = @"0.";
    }
    
    [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:numberPressed];
}

- (IBAction)numberPadSignChangePressed:(UIButton *)sender
{
    if (!self.targetTextInput) {
        return;
    }
    
    UITextRange *entireTextRange = [self.targetTextInput textRangeFromPosition:self.targetTextInput.beginningOfDocument toPosition:self.targetTextInput.endOfDocument];
    NSString *originalText = [self.targetTextInput textInRange:entireTextRange];
    
    // Get the selected text range
    UITextRange *selectedRange = [self.targetTextInput selectedTextRange];
    // Calculate the existing position, relative to the end of the field (will be a - number)
    long pos = [self.targetTextInput offsetFromPosition:self.targetTextInput.endOfDocument toPosition:selectedRange.start];
    
    if (![originalText hasPrefix:@"-"])
    {
        NSString *textWithMinusSign = [@"-" stringByAppendingString:originalText];
        [self textInput:self.targetTextInput replaceTextAtTextRange:entireTextRange withString:textWithMinusSign];
    }
    else
    {
        NSString *textWithoutMinusSign = [originalText stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [self textInput:self.targetTextInput replaceTextAtTextRange:entireTextRange withString:textWithoutMinusSign];
    }
    
    // Work out the position based by offsetting the end of the field to the same offset we had before editing
    UITextPosition *newPos = [self.targetTextInput positionFromPosition:self.targetTextInput.endOfDocument offset:pos];
    // Reselect the range, to move the cursor to that position
    [self.targetTextInput setSelectedTextRange:[self.targetTextInput textRangeFromPosition:newPos toPosition:newPos]];
}
// The 'C' button was just pressed on the number pad
- (IBAction)numberPadClearPressed:(UIButton *)sender
{
    if (!self.targetTextInput) {
        return;
    }
    /* get entire range to delete */
    UITextRange *entireTextRange = [self.targetTextInput textRangeFromPosition:self.targetTextInput.beginningOfDocument toPosition:self.targetTextInput.endOfDocument];
    /* delete the range */
    [self textInput:self.targetTextInput replaceTextAtTextRange:entireTextRange withString:@""];
}

// The backspace button was just pressed on the number pad
- (IBAction)numberPadBackSpacePressedDown:(UIButton *)sender {
    [self deleteCharacters:sender];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(deleteCharacters:) userInfo:nil repeats:YES];
}

// Delete selected characters
- (void)deleteCharacters:(id)sender {
    if (!self.targetTextInput) {
        return;
    }
    
    UITextRange *selectedTextRange = self.targetTextInput.selectedTextRange;
    if (!self.targetTextInput.selectedTextRange) {
        return;
    }
    
    UITextPosition *startPosition;
    if (self.targetTextInput.selectedTextRange.isEmpty)
        startPosition = [self.targetTextInput positionFromPosition:selectedTextRange.start offset:-1];
    else
        startPosition = [self.targetTextInput positionFromPosition:selectedTextRange.start offset:0];
    
    if (!startPosition) {
        return;
    }
    
    UITextPosition *endPosition = selectedTextRange.end;
    if (!endPosition) {
        return;
    }
    
    UITextRange *rangeToDelete = [self.targetTextInput textRangeFromPosition:startPosition toPosition:endPosition];
    
    [self textInput:self.targetTextInput replaceTextAtTextRange:rangeToDelete withString:@""];
}
// Delete button was depressed
- (IBAction)numberPadDeletePressEnded:(UIButton *)sender {
    if (timer != nil)
        [timer invalidate];
    timer = nil;
}

#pragma mark - text replacement routines
// Check delegate methods to see if we should change the characters in range
- (BOOL)textInput:(id <UITextInput>)textInput shouldChangeCharactersInRange:(NSRange)range withString:(NSString *)string
{
    if (!textInput) {
        return NO;
    }
    
    if ([textInput isKindOfClass:[UITextField class]])
    {
        UITextField *textField = (UITextField *)textInput;
        if ([textField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
        {
            if (![textField.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string])
            {
                return NO;
            }
        }
    }
    else if ([textInput isKindOfClass:[UITextView class]])
    {
        UITextView *textView = (UITextView *)textInput;
        if ([textView.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)])
        {
            if (![textView.delegate textView:textView shouldChangeTextInRange:range replacementText:string])
            {
                return NO;
            }
        }
    }
    return YES;
}

// Replace the text of the textInput in textRange with string if the delegate approves
- (void)textInput:(id <UITextInput>)textInput replaceTextAtTextRange:(UITextRange *)textRange withString:(NSString *)string
{
    if (!textInput) {
        return;
    }
    if (!textRange) {
        return;
    }
    
    
    // Calculate the NSRange for the textInput text in the UITextRange textRange:
    long startPos = [textInput offsetFromPosition:textInput.beginningOfDocument toPosition:textRange.start];
    long length = [textInput offsetFromPosition:textRange.start toPosition:textRange.end];
    NSRange selectedRange = NSMakeRange(startPos, length);
    
    if ([self textInput:textInput shouldChangeCharactersInRange:selectedRange withString:string]) {
        // Make the replacement:
        [textInput replaceRange:textRange withText:string];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

