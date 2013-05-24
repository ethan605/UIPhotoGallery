//
//  UIPhotoItemView.m
//  PhotoGallery
//
//  Created by Ethan Nguyen on 5/23/13.
//  Copyright (c) 2013 Ethan Nguyen. All rights reserved.
//

#import "UIPhotoItemView.h"

@interface UIPhotoItemView ()

- (void)tapGestureRecognizer:(UITapGestureRecognizer*)tapGesture;

@end

@implementation UIPhotoItemView

- (id)initWithFrame:(CGRect)frame andSubView:(UIView *)subView {
    if (self = [super initWithFrame:frame]) {
        self.contentSize = self.frame.size;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.delegate = self;
        
        if ([subView isMemberOfClass:[UIImageView class]])
            mainImageView = (UIImageView*)subView;
        
        self.minimumZoomScale = 1;
        self.maximumZoomScale = 1 + (mainImageView != nil);
    
        [self addSubview:subView];
        
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(tapGestureRecognizer:)];
        singleTapGesture.numberOfTapsRequired = 1;
        singleTapGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:singleTapGesture];
        
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(tapGestureRecognizer:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        doubleTapGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:doubleTapGesture];
        
        [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    }
    
    return self;
}

- (void)tapGestureRecognizer:(UITapGestureRecognizer *)tapGesture {
    UIPhotoGalleryView *photoGallery = (UIPhotoGalleryView*)_galleryDelegate;
    
    if (tapGesture.numberOfTapsRequired == 1) {
        if ([photoGallery.delegate respondsToSelector:@selector(photoGallery:didSingleTapViewAtIndex:)])
            [photoGallery.delegate photoGallery:photoGallery didSingleTapViewAtIndex:self.tag];
    } else {
        if ([photoGallery.delegate respondsToSelector:@selector(photoGallery:didDoubleTapViewAtIndex:)])
            [photoGallery.delegate photoGallery:photoGallery didDoubleTapViewAtIndex:self.tag];
        else if (mainImageView)
            [self zoomFromLocation:[tapGesture locationInView:self]];
    }
}

- (void)zoomFromLocation:(CGPoint)zoomLocation {
    CGSize scrollViewSize = self.frame.size;
    
    CGFloat zoomScale = (self.zoomScale == self.maximumZoomScale) ?
    self.minimumZoomScale : self.maximumZoomScale;
    
    CGFloat width = scrollViewSize.width / zoomScale;
    CGFloat height = scrollViewSize.height / zoomScale;
    CGFloat x = zoomLocation.x - (width / 2);
    CGFloat y = zoomLocation.y - (height / 2);
    
    [self zoomToRect:CGRectMake(x, y, width, height) animated:YES];
}

#pragma UIScrollViewDelegate methods
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return mainImageView;
}

@end
