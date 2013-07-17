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

@interface UIPhotoContainerView ()

@end

@implementation UIPhotoContainerView

- (id)initWithFrame:(CGRect)frame andGalleryMode:(UIPhotoGalleryMode)galleryMode withItem:(id)galleryItem {
    CGRect displayFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    if (self = [super initWithFrame:frame]) {
        switch (galleryMode) {
            case UIPhotoGalleryModeImageLocal:
                photoItemView = [[UIPhotoItemView alloc] initWithFrame:displayFrame andLocalImage:galleryItem];
                break;
                
            case UIPhotoGalleryModeImageRemote:
                photoItemView = [[UIPhotoItemView alloc] initWithFrame:displayFrame andRemoteURL:galleryItem];
                break;
                
            default:
                photoItemView = [[UIPhotoItemView alloc] initWithFrame:displayFrame andCustomView:galleryItem];
                break;
        }
        
        [self addSubview:photoItemView];
    }
    
    return self;
}

- (void)setGalleryDelegate:(id<UIPhotoItemDelegate>)galleryDelegate {
    _galleryDelegate = galleryDelegate;
    photoItemView.galleryDelegate = galleryDelegate;
}

- (void)setCaptionWithStyle:(UIPhotoCaptionStyle)captionStyle andItem:(id)captionItem {
    [photoCaptionView removeFromSuperview];
    
    switch (captionStyle) {
        case UIPhotoCaptionStylePlainText:
            photoCaptionView = [[UIPhotoCaptionView alloc] initWithPlainText:captionItem fromFrame:self.frame];
            break;
            
        case UIPhotoCaptionStyleAttributedText:
            photoCaptionView = [[UIPhotoCaptionView alloc] initWithAttributedText:captionItem fromFrame:self.frame];
            break;
            
        default:
            photoCaptionView = [[UIPhotoCaptionView alloc] initWithCustomView:captionItem fromFrame:self.frame];
            break;
    }
    
    [self addSubview:photoCaptionView];
}

- (void)setCaptionHide:(BOOL)hide withAnimation:(BOOL)animated {
    [photoCaptionView setCaptionHide:hide withAnimation:animated];
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

- (id)initWithFrame:(CGRect)frame andLocalImage:(UIImage *)localImage {
    if (self = [self initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
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

- (id)initWithFrame:(CGRect)frame andRemoteURL:(NSURL *)remoteUrl {
    if (self = [self initWithFrame:frame]) {
        UIRemotePhotoItem *remotePhoto = [[UIRemotePhotoItem alloc] initWithFrame:frame andRemoteURL:remoteUrl];
        remotePhoto.photoItemView = self;
        mainImageView = remotePhoto;
        [self addSubview:remotePhoto];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame andCustomView:(UIView *)customView {
    if (self = [self initWithFrame:frame]) {
        [self addSubview:customView];
    }
    
    return self;
}

#pragma private methods
- (void)tapGestureRecognizer:(UITapGestureRecognizer *)tapGesture {
    UIPhotoGalleryView *photoGallery = (UIPhotoGalleryView*)_galleryDelegate;
    
    if (tapGesture.numberOfTapsRequired == 1) {
        if ([photoGallery.delegate respondsToSelector:@selector(photoGallery:didTapAtIndex:)])
            [photoGallery.delegate photoGallery:photoGallery didTapAtIndex:self.tag];
        return;
    }
    
    if (![photoGallery.delegate respondsToSelector:@selector(photoGallery:doubleTapHandlerAtIndex:)]) {
        [self zoomFromLocation:[tapGesture locationInView:self]];
        return;
    }
    
    switch ([photoGallery.delegate photoGallery:photoGallery doubleTapHandlerAtIndex:self.tag]) {
        case UIPhotoGalleryDoubleTapHandlerZoom:
            [self zoomFromLocation:[tapGesture locationInView:self]];
            break;
            
        case UIPhotoGalleryDoubleTapHandlerCustom:
            if ([photoGallery.delegate respondsToSelector:@selector(photoGallery:didDoubleTapAtIndex:)])
                [photoGallery.delegate photoGallery:photoGallery didDoubleTapAtIndex:self.tag];
            
            break;
            
        default:    // UIPhotoGalleryDoubleTapHandlerNone
            break;
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

        double delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [selfDelegate setImageWithURL:remoteUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                if (!error && image) {
                    [activityIndicator removeFromSuperview];

                    CGFloat widthScale = image.size.width / _photoItemView.frame.size.width;
                    CGFloat heightScale = image.size.height / _photoItemView.frame.size.height;
                    _photoItemView.maximumZoomScale = MIN(widthScale, heightScale) * kMaxZoomingScale;
                }
            }];
        });
    }
    
    return self;
}

@end

@interface UIPhotoCaptionView ()

- (UILabel*)captionLabelWithPlainText:(NSString*)plainText
                     orAttributedText:(NSAttributedString*)attributedText
                            fromFrame:(CGRect)frame;

@end

@implementation UIPhotoCaptionView

- (id)initWithPlainText:(NSString *)plainText fromFrame:(CGRect)frame {
    UILabel *captionLabel = [self captionLabelWithPlainText:plainText orAttributedText:nil fromFrame:frame];
    
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
    UILabel *captionLabel = [self captionLabelWithPlainText:nil orAttributedText:attributedText fromFrame:frame];
    
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
                                     frame.size.width, customView.frame.size.height);
    
    if (self = [super initWithFrame:captionFrame]) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:customView];
    }
    
    return self;
}

- (void)setCaptionHide:(BOOL)hide withAnimation:(BOOL)animated {
    if (!self.superview)
        return;
    
    CGRect superViewFrame = self.superview.frame;
    
    if (!animated) {
        CGRect frame = self.frame;
        frame.origin.y = superViewFrame.size.height - (!hide)*self.frame.size.height;
        self.frame = frame;
        self.alpha = !hide;
        return;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.frame;
        frame.origin.y = superViewFrame.size.height - (!hide)*self.frame.size.height;
        self.frame = frame;
        self.alpha = !hide;
    }];
}

- (UILabel*)captionLabelWithPlainText:(NSString *)plainText
                     orAttributedText:(NSAttributedString *)attributedText
                            fromFrame:(CGRect)frame {
    UIFont *captionFont = [UIFont systemFontOfSize:14];
    CGSize captionSize;
    
    if (plainText)
        captionSize = [plainText sizeWithFont:captionFont
                            constrainedToSize:CGSizeMake(frame.size.width, MAXFLOAT)];
    else
        captionSize = [attributedText size];
    
    if (captionSize.height > frame.size.height/3)
        captionSize.height = frame.size.height/3;
    
    UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, captionSize.height)];
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