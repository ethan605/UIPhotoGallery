//
//  UIPhotoItemView.m
//  PhotoGallery
//
//  Created by Ethan Nguyen on 5/23/13.
//  Copyright (c) 2013 Ethan Nguyen. All rights reserved.
//

#import "UIPhotoItemView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface UIRemotePhotoItem : UIImageView

- (id)initWithFrame:(CGRect)frame andRemoteURL:(NSURL *)remoteUrl;

@end

@implementation UIRemotePhotoItem

- (id)initWithFrame:(CGRect)frame andRemoteURL:(NSURL *)remoteUrl {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.autoresizingMask =
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UIActivityIndicatorView *activityIndicator =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.frame = frame;
        [activityIndicator startAnimating];
        
        [self addSubview:activityIndicator];
        
        [self setImageWithURL:remoteUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (!error)
                [activityIndicator removeFromSuperview];
        }];
    }
    
    return self;
}

@end

@interface UIPhotoItemView ()

- (void)tapGestureRecognizer:(UITapGestureRecognizer*)tapGesture;

@end

@implementation UIPhotoItemView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentSize = self.frame.size;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.delegate = self;
        
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

- (id)initWithFrame:(CGRect)frame andLocalImage:(UIImage *)localImage atFrame:(CGRect)imageFrame {
    if (self = [self initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [imageView setImage:localImage];
        
        mainImageView = imageView;
        
        self.minimumZoomScale = 1;
        self.maximumZoomScale = 2;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andRemoteURL:(NSURL *)remoteUrl atFrame:(CGRect)imageFrame {
    if (self = [self initWithFrame:frame]) {
        mainImageView = [[UIRemotePhotoItem alloc] initWithFrame:imageFrame andRemoteURL:remoteUrl];
        [self addSubview:mainImageView];
        
        self.minimumZoomScale = 1;
        self.maximumZoomScale = 2;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andCustomView:(UIView *)customView atFrame:(CGRect)viewFrame {
    if (self = [self initWithFrame:frame]) {
        [self addSubview:customView];
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
        else if (mainImageView.image)
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
