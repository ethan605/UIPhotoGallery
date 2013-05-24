//
//  PGViewController.m
//  PhotoGalleryExample
//
//  Created by Ethan Nguyen on 5/24/13.
//
//

#import "PGViewController.h"
#import "UIPhotoGalleryView.h"

@interface PGViewController () {
    NSArray *sampleURLs;
}

@end

@implementation PGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sampleURLs = @[
                   @"http://l.yimg.com/g/images/bg_error_hold_your_clicks.jpg",
                   @"http://farm9.staticflickr.com/8418/8782168922_c69e58dcd5_z.jpg",
                   @"http://farm8.staticflickr.com/7407/8717876655_13bcca7b16_z.jpg",
                   @"http://farm9.staticflickr.com/8127/8708655358_817632ca88_z.jpg",
                   @"http://farm9.staticflickr.com/8258/8707530059_005b8d30ff_z.jpg",
                   @"http://farm9.staticflickr.com/8137/8707528977_e9662f67b6_z.jpg",
                   @"http://farm9.staticflickr.com/8117/8704889239_a3ba9a50e7_z.jpg",
                   @"http://farm9.staticflickr.com/8280/8706003566_cf3207145a_z.jpg",
                   @"http://farm9.staticflickr.com/8405/8704879333_6fe24e8675_z.jpg",
                   @"http://farm9.staticflickr.com/8258/8705999562_6b39e981d9_z.jpg",
                   @"http://farm9.staticflickr.com/8395/8705998628_4ab56a6746_z.jpg"
                   ];
}

#pragma UIPhotoGalleryDataSource methods
- (NSInteger)numberOfViewsInPhotoGallery:(UIPhotoGalleryView *)photoGallery {
    return 10;
}

- (UIImage*)photoGallery:(UIPhotoGalleryView*)photoGallery localImageAtIndex:(NSInteger)index {
    return [UIImage imageNamed:[NSString stringWithFormat:@"sample%d.jpg", index]];
}

- (NSURL*)photoGallery:(UIPhotoGalleryView *)photoGallery remoteImageURLAtIndex:(NSInteger)index {
    return sampleURLs[index];
}

- (UIView*)photoGallery:(UIPhotoGalleryView *)photoGallery customViewAtIndex:(NSInteger)index {
    CGRect frame = CGRectMake(0, 0, photoGallery.frame.size.width, photoGallery.frame.size.height);
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%d", index+1];
    [view addSubview:label];
    
    return view;
}

#pragma UIPhotoGalleryDelegate methods
- (void)photoGallery:(UIPhotoGalleryView *)photoGallery didTapAtIndex:(NSInteger)index {
}

- (BOOL)photoGallery:(UIPhotoGalleryView *)photoGallery willHandleDoubleTapAtIndex:(NSInteger)index {
    if (photoGallery.galleryMode == UIPhotoGalleryModeImageLocal)
        return YES;
    
    return NO;
}

- (IBAction)segGalleryModeChanged:(UISegmentedControl *)sender {
    vPhotoGallery.galleryMode = (UIPhotoGalleryMode)sender.selectedSegmentIndex;
    
    switch (sender.selectedSegmentIndex) {
        case UIPhotoGalleryModeImageLocal:
            vPhotoGallery.subviewGap = 30;
            vPhotoGallery.verticalGallery = NO;
            vPhotoGallery.peakSubView = YES;
            break;
            
        case UIPhotoGalleryModeImageRemote:
            vPhotoGallery.subviewGap = 30;
            vPhotoGallery.verticalGallery = vPhotoGallery.peakSubView = NO;
            break;
            
        case UIPhotoGalleryModeCustomView:
            vPhotoGallery.subviewGap = 50;
            vPhotoGallery.verticalGallery = vPhotoGallery.peakSubView = YES;
            break;
            
        default:
            break;
    }
    
    [vPhotoGallery layoutSubviews];
}

@end
