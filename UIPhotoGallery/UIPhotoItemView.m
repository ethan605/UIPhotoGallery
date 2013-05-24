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

- (void)setCaptionWithPlainText:(NSString *)plainText {
    [captionView removeFromSuperview];
    captionView = [[UIPhotoCaptionView alloc] initWithPlainText:plainText fromFrame:self.frame];
    [self addSubview:captionView];
}

- (void)setCaptionWithAttributedText:(NSAttributedString *)attributedText {
    [captionView removeFromSuperview];
    captionView = [[UIPhotoCaptionView alloc] initWithAttributedText:attributedText fromFrame:self.frame];
    [self addSubview:captionView];
}

- (void)setCaptionWithCustomView:(UIView *)customView {
    [captionView removeFromSuperview];
    captionView = [[UIPhotoCaptionView alloc] initWithCustomView:customView fromFrame:self.frame];
    [self addSubview:captionView];
}

- (void)setCaptionHide:(BOOL)hide withAnimation:(BOOL)animated {
    [captionView setCaptionHide:hide withAnimation:animated];
}

#pragma private methods
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

@interface UIPhotoCaptionView ()

- (UILabel*)captionLabelWithPlainText:(NSString*)plainText orAttributedText:(NSAttributedString*)attributedText;

@end

@implementation UIPhotoCaptionView

- (id)initWithPlainText:(NSString *)plainText fromFrame:(CGRect)frame {
    UILabel *captionLabel = [self captionLabelWithPlainText:plainText orAttributedText:nil];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:captionLabel.frame];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0.6;
    
    CGRect captionFrame = CGRectMake(0, frame.size.height-captionLabel.frame.size.height,
                                     captionLabel.frame.size.width, captionLabel.frame.size.height);
    
    if (self = [super initWithFrame:captionFrame]) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:backgroundView];
        [self addSubview:captionLabel];
    }

    return self;
}

- (id)initWithAttributedText:(NSAttributedString *)attributedText fromFrame:(CGRect)frame {
    UILabel *captionLabel = [self captionLabelWithPlainText:nil orAttributedText:attributedText];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:captionLabel.frame];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0.6;
    
    CGRect captionFrame = CGRectMake(0, frame.size.height-captionLabel.frame.size.height,
                                     captionLabel.frame.size.width, captionLabel.frame.size.height);
    
    if (self = [super initWithFrame:captionFrame]) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:backgroundView];
        [self addSubview:captionLabel];
    }
    
    return self;
}

- (id)initWithCustomView:(UIView *)customView fromFrame:(CGRect)frame {
    CGRect captionFrame = CGRectMake(0, frame.size.height-customView.frame.size.height,
                                     customView.frame.size.width, customView.frame.size.height);
    
    if (self = [super initWithFrame:captionFrame]) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    }
    
    return self;
}

- (void)setCaptionHide:(BOOL)hide withAnimation:(BOOL)animated {
    if (self.superview)
        return;
    
    CGRect superViewFrame = self.superview.frame;
    
    if (!animated) {
        CGRect frame = self.frame;
        frame.origin.y = superViewFrame.size.height;
        self.frame = frame;
        return;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.frame;
        frame.origin.y = superViewFrame.size.height - (!hide)*self.frame.size.height;
        self.frame = frame;
    }];
}

- (UILabel*)captionLabelWithPlainText:(NSString *)plainText orAttributedText:(NSAttributedString *)attributedText {
    UIFont *captionFont = [UIFont systemFontOfSize:14];
    CGSize captionSize = [plainText sizeWithFont:captionFont
                               constrainedToSize:CGSizeMake(self.frame.size.width, MAXFLOAT)];
    
    if (captionSize.height > self.frame.size.height/3)
        captionSize.height = self.frame.size.height/3;
    
    UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,
                                                                      self.frame.size.width, captionSize.height)];
    captionLabel.backgroundColor = [UIColor clearColor];
    captionLabel.font = captionFont;
    captionLabel.numberOfLines = 0;
    captionLabel.textColor = [UIColor whiteColor];
    
    if (plainText)
        captionLabel.text = plainText;
    else if (attributedText)
        captionLabel.attributedText = attributedText;
    
    return captionLabel;
}

@end