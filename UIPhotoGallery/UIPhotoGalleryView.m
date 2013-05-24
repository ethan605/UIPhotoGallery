//
//  UIPhotoGalleryView.m
//  PhotoGallery
//
//  Created by Ethan Nguyen on 5/23/13.
//  Copyright (c) 2013 Ethan Nguyen. All rights reserved.
//

#import "UIPhotoGalleryView.h"
#import "UIPhotoItemView.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define kDefaultSubviewGap              30
#define kMaxSpareViews                  2

@interface UIPhotoGalleryView ()

- (void)initMainScrollView;
- (void)setupMainScrollView;
- (BOOL)reusableViewsContainViewAtIndex:(NSInteger)index;
- (void)populateSubviews;
- (UIView*)viewToBeAddedAtIndex:(NSInteger)index;

@end

@implementation UIPhotoGalleryView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initMainScrollView];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initMainScrollView];
}

- (void)layoutSubviews {
    [self setupMainScrollView];
}

#pragma get-set methods
- (void)setGalleryMode:(UIPhotoGalleryMode)galleryMode {
    _galleryMode = galleryMode;
    [self layoutSubviews];
}

- (void)setCircleScroll:(BOOL)circleScroll {
    _circleScroll = circleScroll;
    
    if (_circleScroll) {
        circleScrollViews = [NSMutableArray array];
        
        for (NSInteger index = -2; index < 2; index++) {
            NSInteger indexToAdd = (dataSourceNumOfViews + index) % dataSourceNumOfViews;
            UIView *viewToAdd = [self viewToBeAddedAtIndex:indexToAdd];
            [circleScrollViews addObject:viewToAdd];
            
//            CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
//            
//            if (_verticalGallery)
//                frame.origin.y = assertIndex * mainScrollView.frame.size.height;
//            else
//                frame.origin.x = assertIndex * mainScrollView.frame.size.width;
//            
//            UIView *viewToAdd = [self viewToBeAddedAtIndex:assertIndex];
//            
//            UIPhotoItemView *subView = [[UIPhotoItemView alloc] initWithFrame:frame andSubView:viewToAdd];
//            subView.tag = currentPage + index;
//            subView.galleryDelegate = self;
        }
    } else {
        for (UIView *view in circleScrollViews)
            [view removeFromSuperview];
        
        circleScrollViews = nil;
    }
}

- (void)setPeakSubView:(BOOL)peakSubView {
    _peakSubView = peakSubView;
    mainScrollView.clipsToBounds = _peakSubView;
}

- (void)setVerticalGallery:(BOOL)verticalGallery {
    _verticalGallery = verticalGallery;
    [self setSubviewGap:_subviewGap];
    [self setInitialIndex:_initialIndex];
}

- (void)setSubviewGap:(CGFloat)subviewGap {
    _subviewGap = subviewGap;
    
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    if (_verticalGallery)
        frame.size.height += _subviewGap;
    else
        frame.size.width += _subviewGap;
    
    mainScrollView.frame = frame;
    mainScrollView.contentSize = frame.size;
}

- (void)setInitialIndex:(NSInteger)initialIndex {
    _initialIndex = initialIndex;
    currentPage = _initialIndex;
    [self populateSubviews];
    
    CGPoint contentOffset = mainScrollView.contentOffset;
    
    if (_verticalGallery)
        contentOffset.y = currentPage * mainScrollView.frame.size.height;
    else
        contentOffset.x = currentPage * mainScrollView.frame.size.width;
    
    mainScrollView.contentOffset = contentOffset;
}

#pragma UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger newPage;
    
    if (_verticalGallery)
        newPage = scrollView.contentOffset.y / scrollView.frame.size.height;
    else
        newPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    if (newPage != currentPage) {
        currentPage = newPage;
        [self populateSubviews];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate)
        return;
    
    [self scrollViewDidEndDecelerating:scrollView];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView.tag == -1 || ![scrollView.subviews[0] isMemberOfClass:[UIImageView class]])
        return nil;
    
//    DLog(@"%d", scrollView.tag);
    
    return scrollView.subviews[0];
}

#pragma private methods
- (void)initMainScrollView {
    _galleryMode = UIPhotoGalleryModeCustomView;
    _subviewGap = kDefaultSubviewGap;
    _verticalGallery = NO;
    _initialIndex = 0;
    
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    if (_verticalGallery)
        frame.size.height += _subviewGap;
    else
        frame.size.width += _subviewGap;
    
    mainScrollView = [[UIScrollView alloc] initWithFrame:frame];
    mainScrollView.autoresizingMask = self.autoresizingMask;
    mainScrollView.contentSize = frame.size;
    mainScrollView.pagingEnabled = YES;
    mainScrollView.backgroundColor = [UIColor clearColor];
    mainScrollView.delegate = self;
    mainScrollView.showsHorizontalScrollIndicator = mainScrollView.showsVerticalScrollIndicator = NO;
    mainScrollView.clipsToBounds = NO;
    mainScrollView.tag = -1;
    
    [self addSubview:mainScrollView];
    
    reusableViews = [NSMutableSet set];
    currentPage = 0;
}

- (void)setupMainScrollView {
    NSAssert(_dataSource != nil, @"Missing dataSource");
    NSAssert([_dataSource respondsToSelector:@selector(numberOfViewsInPhotoGallery:)],
             @"Missing dataSource method numberOfViewsInPhotoGallery:");
    
    switch (_galleryMode) {
        case UIPhotoGalleryModeImageLocal:
            NSAssert([_dataSource respondsToSelector:@selector(photoGallery:localImageAtIndex:)],
                     @"UIPhotoGalleryModeImageLocal mode missing dataSource method photoGallery:localImageAtIndex:");
            break;
            
        case UIPhotoGalleryModeImageRemote:
            NSAssert([_dataSource respondsToSelector:@selector(photoGallery:remoteImageURLAtIndex:)],
                     @"UIPhotoGalleryModeImageRemote mode missing dataSource method photoGallery:remoteImageURLAtIndex:");
            break;
            
        case UIPhotoGalleryModeCustomView:
            NSAssert([_dataSource respondsToSelector:@selector(photoGallery:customViewAtIndex:)],
                     @"UIPhotoGalleryModeCustomView mode missing dataSource method photoGallery:viewAtIndex:");
            break;
            
        default:
            break;
    }
    
    dataSourceNumOfViews = [_dataSource numberOfViewsInPhotoGallery:self];
    
    NSInteger tmpCurrentPage = currentPage;
    [self setSubviewGap:_subviewGap];
    currentPage = tmpCurrentPage;
    
    CGSize contentSize = mainScrollView.contentSize;
    
    if (_verticalGallery)
        contentSize.height = mainScrollView.frame.size.height * dataSourceNumOfViews;
    else
        contentSize.width = mainScrollView.frame.size.width * dataSourceNumOfViews;
    
    mainScrollView.contentSize = contentSize;
    
    for (UIView *view in mainScrollView.subviews)
        [view removeFromSuperview];
    
    [reusableViews removeAllObjects];
    
    [self populateSubviews];
    [self setInitialIndex:currentPage];
}

- (BOOL)reusableViewsContainViewAtIndex:(NSInteger)index {
    for (UIView *view in reusableViews)
        if (view.tag == index)
            return YES;
    
    return NO;
}

- (void)populateSubviews {
    NSMutableSet *toRemovedViews = [NSMutableSet set];
    
    for (UIView *view in reusableViews)
        if (view.tag < currentPage - kMaxSpareViews || view.tag > currentPage + kMaxSpareViews) {
            [toRemovedViews addObject:view];
            [view removeFromSuperview];
        }
    
    [reusableViews minusSet:toRemovedViews];

    for (NSInteger index = -kMaxSpareViews; index <= kMaxSpareViews; index++) {
        NSInteger assertIndex = currentPage + index;
        if (assertIndex < 0 || assertIndex >= dataSourceNumOfViews ||
            [self reusableViewsContainViewAtIndex:assertIndex])
            continue;
        
        CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        
        if (_verticalGallery)
            frame.origin.y = assertIndex * mainScrollView.frame.size.height;
        else
            frame.origin.x = assertIndex * mainScrollView.frame.size.width;
        
        UIView *viewToAdd = [self viewToBeAddedAtIndex:assertIndex];
        
        UIPhotoItemView *subView = [[UIPhotoItemView alloc] initWithFrame:frame andSubView:viewToAdd];
        subView.tag = currentPage + index;
        subView.galleryDelegate = self;
        
        [mainScrollView addSubview:subView];
        [reusableViews addObject:subView];
    }
}

- (UIView*)viewToBeAddedAtIndex:(NSInteger)index {
    switch (_galleryMode) {
        case UIPhotoGalleryModeImageLocal: {
            UIImage *image = [_dataSource photoGallery:self localImageAtIndex:index];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:
                                      CGRectMake(0, 0,
                                                 mainScrollView.frame.size.width,
                                                 mainScrollView.frame.size.height)];
            imageView.backgroundColor = [UIColor clearColor];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [imageView setImage:image];
            
            return imageView;
        }
            
        case UIPhotoGalleryModeImageRemote: {
            NSURL *url = [_dataSource photoGallery:self remoteImageURLAtIndex:index];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:
                                      CGRectMake(0, 0,
                                                 mainScrollView.frame.size.width,
                                                 mainScrollView.frame.size.height)];
            imageView.backgroundColor = [UIColor clearColor];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [imageView setImageWithURL:url];
            
            return imageView;
        }
            
        case UIPhotoGalleryModeCustomView:
            return [_dataSource photoGallery:self customViewAtIndex:index];

        default:
            return nil;
    }
}

@end
