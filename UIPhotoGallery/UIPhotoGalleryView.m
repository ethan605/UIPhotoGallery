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
- (UIPhotoContainerView*)viewToBeAddedWithFrame:(CGRect)frame atIndex:(NSInteger)index;

@end

@implementation UIPhotoGalleryView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask =
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
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

- (void)setCaptionStyle:(UIPhotoCaptionStyle)captionStyle {
    _captionStyle = captionStyle;
    [self layoutSubviews];
}

- (void)setCircleScroll:(BOOL)circleScroll {
    _circleScroll = circleScroll;
    
//    if (_circleScroll) {
//        circleScrollViews = [NSMutableArray array];
//        
//        for (NSInteger index = -2; index < 2; index++) {
//            NSInteger indexToAdd = (dataSourceNumOfViews + index) % dataSourceNumOfViews;
//            UIView *viewToAdd = [self viewToBeAddedAtIndex:indexToAdd];
//            [circleScrollViews addObject:viewToAdd];
    
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
//        }
//    } else {
//        for (UIView *view in circleScrollViews)
//            [view removeFromSuperview];
//        
//        circleScrollViews = nil;
//    }
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
    [self setInitialIndex:initialIndex animated:NO];
}

- (void)setInitialIndex:(NSInteger)initialIndex animated:(BOOL)animation {
    _initialIndex = initialIndex;
    currentPage = _initialIndex;
    
    [self scrollToPage:currentPage animated:animation];
}

#pragma public methods
- (BOOL)scrollToPage:(NSInteger)page animated:(BOOL)animation {
    if (page < 0 || page >= dataSourceNumOfViews)
        return NO;
    
    currentPage = page;
    [self populateSubviews];
    
    CGPoint contentOffset = mainScrollView.contentOffset;
    
    if (_verticalGallery)
        contentOffset.y = currentPage * mainScrollView.frame.size.height;
    else
        contentOffset.x = currentPage * mainScrollView.frame.size.width;
    
    [mainScrollView setContentOffset:contentOffset animated:animation];

    return YES;
}

- (BOOL)scrollToBesidePage:(NSInteger)delta animated:(BOOL)animation {
    return [self scrollToPage:currentPage+delta animated:animation];
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

#pragma private methods
- (void)initMainScrollView {
    _galleryMode = UIPhotoGalleryModeImageLocal;
    _captionStyle = UIPhotoCaptionStylePlainText;
    _subviewGap = kDefaultSubviewGap;
    _peakSubView = NO;
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
    
    CGSize contentSize = mainScrollView.contentSize;
    
    if (_verticalGallery)
        contentSize.height = mainScrollView.frame.size.height * dataSourceNumOfViews;
    else
        contentSize.width = mainScrollView.frame.size.width * dataSourceNumOfViews;
    
    mainScrollView.contentSize = contentSize;
    
    for (UIView *view in mainScrollView.subviews)
        [view removeFromSuperview];
    [reusableViews removeAllObjects];
    
    [self scrollToPage:tmpCurrentPage animated:NO];
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
        
        UIPhotoContainerView *subView = [self viewToBeAddedWithFrame:frame atIndex:currentPage+index];
        
        if (subView) {
            [mainScrollView addSubview:subView];
            [reusableViews addObject:subView];
        }
    }
}

- (UIPhotoContainerView*)viewToBeAddedWithFrame:(CGRect)frame atIndex:(NSInteger)index {
    UIPhotoContainerView *subView = nil;
    id galleryItem = nil;
    
    switch (_galleryMode) {
        case UIPhotoGalleryModeImageLocal:
            galleryItem = [_dataSource photoGallery:self localImageAtIndex:index];
            break;
            
        case UIPhotoGalleryModeImageRemote:
            galleryItem = [_dataSource photoGallery:self remoteImageURLAtIndex:index];
            break;

        default:
            galleryItem = [_dataSource photoGallery:self customViewAtIndex:index];
            break;
    }
    
    if (!galleryItem)
        return nil;
    
    subView = [[UIPhotoContainerView alloc] initWithFrame:frame andGalleryMode:_galleryMode withItem:galleryItem];
    subView.tag = index;
    subView.galleryDelegate = self;
    
    if (!subView)
        return nil;
    
    id captionItem = nil;
    
    switch (_captionStyle) {
        case UIPhotoCaptionStylePlainText:
            if ([_dataSource respondsToSelector:@selector(photoGallery:plainTextCaptionAtIndex:)])
                captionItem = [_dataSource photoGallery:self plainTextCaptionAtIndex:index];

            break;
            
        case UIPhotoCaptionStyleAttributedText:
            if ([_dataSource respondsToSelector:@selector(photoGallery:attributedTextCaptionAtIndex:)])
                captionItem = [_dataSource photoGallery:self attributedTextCaptionAtIndex:index];
            
            break;
            
        default:
            if ([_dataSource respondsToSelector:@selector(photoGallery:customViewAtIndex:)])
                captionItem = [_dataSource photoGallery:self customViewCaptionAtIndex:index];
            
            break;
    }
    
    if (captionItem)
        [subView setCaptionWithStyle:_captionStyle andItem:captionItem];
    
    return subView;
}

@end
