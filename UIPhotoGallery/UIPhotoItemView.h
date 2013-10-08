//
//  UIPhotoItemView.h
//  PhotoGallery
//
//  Created by Ethan Nguyen on 5/23/13.
//  Copyright (c) 2013 Ethan Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPhotoGalleryView.h"

@class UIRemotePhotoItem, UIPhotoCaptionView, UIPhotoItemView;

@interface UIPhotoContainerView : UIView {
    UIPhotoItemView *photoItemView;
    UIPhotoCaptionView *photoCaptionView;
}

@property (nonatomic, assign) id<UIPhotoItemDelegate> galleryDelegate;

- (id)initWithFrame:(CGRect)frame andGalleryMode:(UIPhotoGalleryMode)galleryMode withItem:(id)galleryItem;
- (void)setCaptionWithStyle:(UIPhotoCaptionStyle)captionStyle andItem:(id)captionItem;
- (void)setCaptionHide:(BOOL)hide withAnimation:(BOOL)animated;

@end

@interface UIPhotoItemView : UIScrollView <UIScrollViewDelegate> {
@private
    UIImageView *mainImageView;
    UIPhotoCaptionView *captionView;
}

@property (nonatomic, assign) id<UIPhotoItemDelegate> galleryDelegate;

- (id)initWithFrame:(CGRect)frame andLocalImage:(UIImage*)localImage;
- (id)initWithFrame:(CGRect)frame andRemoteURL:(NSURL*)remoteUrl;
- (id)initWithFrame:(CGRect)frame andCustomView:(UIView*)customView;

@end

@interface UIRemotePhotoItem : UIImageView

@property (nonatomic, assign) UIPhotoItemView *photoItemView;

- (id)initWithFrame:(CGRect)frame andRemoteURL:(NSURL *)remoteUrl;

@end

@interface UIPhotoCaptionView : UIView

- (id)initWithPlainText:(NSString*)plainText fromFrame:(CGRect)frame;
- (id)initWithAttributedText:(NSAttributedString*)attributedText fromFrame:(CGRect)frame;
- (id)initWithCustomView:(UIView*)customView fromFrame:(CGRect)frame;

- (void)setCaptionHide:(BOOL)hide withAnimation:(BOOL)animated;

@end