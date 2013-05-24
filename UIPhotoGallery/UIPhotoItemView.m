//
//  UIPhotoItemView.m
//  PhotoGallery
//
//  Created by Ethan Nguyen on 5/23/13.
//  Copyright (c) 2013 Ethan Nguyen. All rights reserved.
//

#import "UIPhotoItemView.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define kMaxZoomingScale            2

@interface UIRemotePhotoItem : UIImageView

@property (nonatomic, strong) UIPhotoItemView *photoItemView;

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
        
        UIRemotePhotoItem *selfDelegate = self;
        
        [selfDelegate setImageWithURL:remoteUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (!error && image) {
                [activityIndicator removeFromSuperview];
                
                CGFloat widthScale = image.size.width / _photoItemView.frame.size.width;
                CGFloat heightScale = image.size.height / _photoItemView.frame.size.height;
                _photoItemView.maximumZoomScale = MIN(widthScale, heightScale) * kMaxZoomingScale;
            }
        }];
    }
    
    return self;
}

@end

@interface UIPhotoItemView ()

- (void)tapGestureRecognizer:(UITapGestureRecognizer*)tapGesture;
- (void)zoomFromLocation:(CGPoint)zoomLocation;

@end

@implementation UIPhotoItemView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentSize = self.frame.size;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.delegate = self;
        self.minimumZoomScale = 1;
        
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
        [self addSubview:imageView];
        
        CGFloat widthScale = localImage.size.width / self.frame.size.width;
        CGFloat heightScale = localImage.size.height / self.frame.size.height;
        self.maximumZoomScale = MIN(widthScale, heightScale) * kMaxZoomingScale;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andRemoteURL:(NSURL *)remoteUrl atFrame:(CGRect)imageFrame {
    if (self = [self initWithFrame:frame]) {
        UIRemotePhotoItem *remotePhoto = [[UIRemotePhotoItem alloc] initWithFrame:imageFrame andRemoteURL:remoteUrl];
        remotePhoto.photoItemView = self;
        mainImageView = remotePhoto;
        [self addSubview:remotePhoto];
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
        if ([photoGallery.delegate respondsToSelector:@selector(photoGallery:didTapAtIndex:)])
            [photoGallery.delegate photoGallery:photoGallery didTapAtIndex:self.tag];
    } else {
        if (([photoGallery.delegate respondsToSelector:@selector(photoGallery:willHandleDoubleTapAtIndex:)] &&
             [photoGallery.delegate photoGallery:photoGallery willHandleDoubleTapAtIndex:self.tag]) ||
            ![photoGallery.delegate respondsToSelector:@selector(photoGallery:willHandleDoubleTapAtIndex:)])
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
