//
//  UIPhotoItemView.h
//  PhotoGallery
//
//  Created by Ethan Nguyen on 5/23/13.
//  Copyright (c) 2013 Ethan Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPhotoGalleryView.h"

@class UIRemotePhotoItem, UIPhotoCaptionView;

@interface UIPhotoItemView : UIScrollView <UIScrollViewDelegate> {
@private
    UIImageView *mainImageView;
    UIPhotoCaptionView *captionView;
}

@property (nonatomic, assign) id<UIPhotoItemDelegate> galleryDelegate;

- (id)initWithFrame:(CGRect)frame andLocalImage:(UIImage*)localImage atFrame:(CGRect)imageFrame;
- (id)initWithFrame:(CGRect)frame andRemoteURL:(NSURL*)remoteUrl atFrame:(CGRect)imageFrame;
- (id)initWithFrame:(CGRect)frame andCustomView:(UIView*)customView atFrame:(CGRect)viewFrame;

- (void)setCaptionWithPlainText:(NSString*)plainText;
- (void)setCaptionWithAttributedText:(NSAttributedString*)attributedText;
- (void)setCaptionWithCustomView:(UIView*)customView;
- (void)setCaptionHide:(BOOL)hide withAnimation:(BOOL)animated;

@end

@interface UIRemotePhotoItem : UIImageView

@property (nonatomic, strong) UIPhotoItemView *photoItemView;

- (id)initWithFrame:(CGRect)frame andRemoteURL:(NSURL *)remoteUrl;

@end

@interface UIPhotoCaptionView : UIView

- (id)initWithPlainText:(NSString*)plainText fromFrame:(CGRect)frame;
- (id)initWithAttributedText:(NSAttributedString*)attributedText fromFrame:(CGRect)frame;
- (id)initWithCustomView:(UIView*)customView fromFrame:(CGRect)frame;

- (void)setCaptionHide:(BOOL)hide withAnimation:(BOOL)animated;


@end