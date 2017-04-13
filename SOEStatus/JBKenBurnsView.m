//
//  KenBurnsView.m
//  KenBurns
//
//  Created by Javier Berlana on 9/23/11.
//  Copyright (c) 2011, Javier Berlana
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this
//  software and associated documentation files (the "Software"), to deal in the Software
//  without restriction, including without limitation the rights to use, copy, modify, merge,
//  publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
//  to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies
//  or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
//  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "JBKenBurnsView.h"
#include <stdlib.h>

#define enlargeRatio 1.2
#define imageBufer 3

// Private interface
@interface JBKenBurnsView () {
    NSMutableArray *_imagesArray;
    CGFloat _showImageDuration;
    NSInteger _currentIndex;
    BOOL _shouldLoop;
    BOOL _isLandscape;
}

@property (nonatomic, assign) int currentImage;

@property (nonatomic, strong) NSTimer *nextImageTimer;
@property (nonatomic, strong) NSRunLoop *timerRunLoop;;

@end


@implementation JBKenBurnsView

-(id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.layer removeAllAnimations];
    [self timerInvalidate];
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.layer.masksToBounds = YES;
}

- (void) animateWithImages:(NSArray *)images transitionDuration:(float)duration loop:(BOOL)shouldLoop isLandscape:(BOOL)isLandscape {
    [self _startAnimationsWithData:images transitionDuration:duration loop:shouldLoop isLandscape:isLandscape];
}

- (void)_startAnimationsWithData:(NSArray *)data transitionDuration:(float)duration loop:(BOOL)shouldLoop isLandscape:(BOOL)isLandscape
{
    _imagesArray        = [data mutableCopy];
    _showImageDuration  = duration;
    _shouldLoop         = shouldLoop;
    _isLandscape        = isLandscape;
    
    // start at 0
    _currentIndex       = -1;
    
    [self timerInvalidate];
    [self.layer removeAllAnimations];
    
    self.nextImageTimer = [NSTimer timerWithTimeInterval:duration target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    self.timerRunLoop = [NSRunLoop mainRunLoop];
    [self.timerRunLoop addTimer:self.nextImageTimer forMode:NSRunLoopCommonModes];
    [self nextImage];
}

- (void)nextImage {
    _currentIndex++;
    
    UIImage *image = nil;
    id imageSource = _imagesArray[_currentIndex];
    if ([imageSource isKindOfClass:[UIImage class]]) {
        image = _imagesArray[_currentIndex];
    } else if ([imageSource isKindOfClass:[NSURL class]]) {
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:_imagesArray[_currentIndex]]];
    } else if ([imageSource isKindOfClass:[NSString class]]) {
        image = [UIImage imageWithContentsOfFile:_imagesArray[_currentIndex]];
    } else {
        NSLog(@"Unrecognized image type: %@", NSStringFromClass([imageSource class]));
    }
    
    if (!image) return;
    
    UIImageView *imageView = nil;
    
    float resizeRatio   = -1;
    float widthDiff     = -1;
    float heightDiff    = -1;
    float originX       = -1;
    float originY       = -1;
    float zoomInX       = -1;
    float zoomInY       = -1;
    float moveX         = -1;
    float moveY         = -1;
    float frameWidth    = _isLandscape? self.frame.size.width : self.frame.size.height;
    float frameHeight   = _isLandscape? self.frame.size.height : self.frame.size.width;
    
    // Wider than screen
    if (image.size.width > frameWidth)
    {
        widthDiff  = image.size.width - frameWidth;
        
        // Higher than screen
        if (image.size.height > frameHeight)
        {
            heightDiff = image.size.height - frameHeight;
            
            if (widthDiff > heightDiff)
                resizeRatio = frameWidth / image.size.width;
            else
                resizeRatio = frameHeight / image.size.height;
            
            // No higher than screen
        }
        else
        {
            heightDiff = frameHeight - image.size.height;
            
            if (widthDiff > heightDiff)
                resizeRatio = frameWidth / image.size.width;
            else
                resizeRatio = self.bounds.size.height / image.size.height;
        }
        
        // No wider than screen
    }
    else
    {
        widthDiff  = frameWidth - image.size.width;
        
        // Higher than screen
        if (image.size.height > frameHeight)
        {
            heightDiff = image.size.height - frameHeight;
            
            if (widthDiff > heightDiff)
                resizeRatio = image.size.height / frameHeight;
            else
                resizeRatio = frameWidth / image.size.width;
            
            // No higher than screen
        }
        else
        {
            heightDiff = frameHeight - image.size.height;
            
            if (widthDiff > heightDiff)
                resizeRatio = frameWidth / image.size.width;
            else
                resizeRatio = frameHeight / image.size.height;
        }
    }
    
    // Resize the image.
    float optimusWidth  = (image.size.width * resizeRatio) * enlargeRatio;
    float optimusHeight = (image.size.height * resizeRatio) * enlargeRatio;
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, optimusWidth, optimusHeight)];
    
    // Calcule the maximum move allowed.
    float maxMoveX = optimusWidth - frameWidth;
    float maxMoveY = optimusHeight - frameHeight;
    
    float rotation = (arc4random() % 9) / 100;
    
    switch (arc4random() % 4) {
        case 0:
            originX = 0;
            originY = 0;
            zoomInX = 1.25;
            zoomInY = 1.25;
            moveX   = -maxMoveX;
            moveY   = -maxMoveY;
            break;
            
        case 1:
            originX = 0;
            originY = frameHeight - optimusHeight;
            zoomInX = 1.10;
            zoomInY = 1.10;
            moveX   = -maxMoveX;
            moveY   = maxMoveY;
            break;
            
            
        case 2:
            originX = frameWidth - optimusWidth;
            originY = 0;
            zoomInX = 1.30;
            zoomInY = 1.30;
            moveX   = maxMoveX;
            moveY   = -maxMoveY;
            break;
            
        case 3:
            originX = frameWidth - optimusWidth;
            originY = frameHeight - optimusHeight;
            zoomInX = 1.20;
            zoomInY = 1.20;
            moveX   = maxMoveX;
            moveY   = maxMoveY;
            break;
            
        default:
            NSLog(@"Unknown random number found in JBKenBurnsView _animate");
            break;
    }
    
    
    CALayer *picLayer    = [CALayer layer];
    picLayer.contents    = (id)image.CGImage;
    picLayer.anchorPoint = CGPointMake(0, 0);
    picLayer.bounds      = CGRectMake(0, 0, optimusWidth, optimusHeight);
    picLayer.position    = CGPointMake(originX, originY);
    
    [imageView.layer addSublayer:picLayer];
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:1];
    [animation setType:kCATransitionFade];
    [[self layer] addAnimation:animation forKey:nil];
    
    // Remove the previous view
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    [self addSubview:imageView];
    
    // Generates the animation
    [UIView animateWithDuration:(_showImageDuration + 2) delay:0 options:(UIViewAnimationCurveEaseIn) animations:^{
        CGAffineTransform rotate    = CGAffineTransformMakeRotation(rotation);
        CGAffineTransform moveRight = CGAffineTransformMakeTranslation(moveX, moveY);
        CGAffineTransform combo1    = CGAffineTransformConcat(rotate, moveRight);
        CGAffineTransform zoomIn    = CGAffineTransformMakeScale(zoomInX, zoomInY);
        CGAffineTransform transform = CGAffineTransformConcat(zoomIn, combo1);
        imageView.transform = transform;
    } completion:^(BOOL finished){
        [self _notifyDelegate];
        
        if (_currentIndex == _imagesArray.count - 1) {
            if (_shouldLoop) {
                _currentIndex = -1;
            } else {
                [self timerInvalidate];
            }
        }
    }];
}

- (void) _notifyDelegate
{
    if (_delegate) {
        if([_delegate respondsToSelector:@selector(didShowImageAtIndex:)])
        {
            [_delegate didShowImageAtIndex:_currentIndex];
        }
        
        if (_currentIndex == ([_imagesArray count] - 1) && !_shouldLoop && [_delegate respondsToSelector:@selector(didFinishAllAnimations)]) {
            [_delegate didFinishAllAnimations];
        }
    }
}

- (void)timerInvalidate {
    [self.timerRunLoop performSelector:@selector(invalidate) target:self.nextImageTimer argument:nil order:10 modes:@[NSRunLoopCommonModes]];
    if (self.timerRunLoop != [NSRunLoop mainRunLoop]) {
        [self.timerRunLoop runUntilDate:[NSDate date]];
    }
}

- (void)flush {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self timerInvalidate];
    [self.layer removeAllAnimations];
    _imagesArray = nil;
}

@end
