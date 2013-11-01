//
//  UIPhotoGalleryViewController.h
//  PhotoGalleryExample
//
//  Created by Ethan Nguyen on 5/24/13.
//
//

#import <UIKit/UIKit.h>
#import "UIPhotoGalleryView.h"

@interface UIPhotoGalleryViewController : UIViewController<UIPhotoGalleryDataSource, UIPhotoGalleryDelegate>

@property(nonatomic, strong, readonly) UIPhotoGalleryView *vPhotoGallery;

@property (nonatomic, assign) id<UIPhotoGalleryDataSource> dataSource;

@property (nonatomic, assign) UIPhotoGalleryMode galleryMode;
@property (nonatomic, assign) UIPhotoCaptionStyle captionStyle;
@property (nonatomic, assign) BOOL circleScroll;
@property (nonatomic, assign) BOOL showStatusBar;
@property (nonatomic, assign) BOOL peakSubView;
@property (nonatomic, assign) BOOL verticalGallery;
@property (nonatomic, assign) BOOL scrollToInitIdxAnimated;
@property (nonatomic, assign) BOOL dismissAnimated;
@property (nonatomic, assign) CGFloat subviewGap;
@property (nonatomic, assign) NSInteger initialIndex;

@end
