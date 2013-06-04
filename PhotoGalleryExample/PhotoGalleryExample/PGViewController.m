//
//  PGViewController.m
//  PhotoGalleryExample
//
//  Created by Ethan Nguyen on 5/24/13.
//
//

#import "PGViewController.h"
#import "UIPhotoGalleryView.h"
#import "UIPhotoGalleryViewController.h"

@interface PGViewController () {
    NSArray *sampleURLs;
}

@end

@implementation PGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    vPhotoGallery.initialIndex = 4;
    vPhotoGallery.showsScrollIndicator = NO;
    
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
    return [UIImage imageNamed:[NSString stringWithFormat:@"sample%d.jpg", index % 10]];
}

- (NSURL*)photoGallery:(UIPhotoGalleryView *)photoGallery remoteImageURLAtIndex:(NSInteger)index {
    return sampleURLs[index % 10];
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

- (NSString*)photoGallery:(UIPhotoGalleryView *)photoGallery plainTextCaptionAtIndex:(NSInteger)index {
    return sampleURLs[index % 10];
}

- (NSAttributedString*)photoGallery:(UIPhotoGalleryView *)photoGallery attributedTextCaptionAtIndex:(NSInteger)index {
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:sampleURLs[index]];
    [attributedText addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(3,5)];
    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(10,7)];
    [attributedText addAttribute:NSFontAttributeName
                           value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0]
                           range:NSMakeRange(20, 10)];
    return attributedText;
}

- (UIView*)photoGallery:(UIPhotoGalleryView *)photoGallery customViewCaptionAtIndex:(NSInteger)index {
    UILabel *customView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    customView.text = sampleURLs[index];
    
    return customView;
}

//- (UIView*)customTopViewForGalleryViewController:(UIPhotoGalleryViewController *)galleryViewController {
//    CGFloat width = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
//    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 40)];
//    topView.backgroundColor = [UIColor whiteColor];
//    
//    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeInfoDark];
//    btnClose.frame = CGRectMake(width-30, 10, 20, 20);
//    btnClose.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//    [btnClose setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    [btnClose addTarget:self
//                 action:@selector(goBackFromGallery)
//       forControlEvents:UIControlEventTouchUpInside];
//    [topView addSubview:btnClose];
//    
//    return topView;
//}

- (UIView*)customTopViewForGalleryViewController:(UIPhotoGalleryViewController *)galleryViewController {
    return nil;
}

//- (UIView*)customBottomViewForGalleryViewController:(UIPhotoGalleryViewController *)galleryViewController {
//    return nil;
//}

- (void)goBackFromGallery {
    if (photoGalleryVC.navigationController)
        [photoGalleryVC.navigationController popViewControllerAnimated:YES];
    else
        [photoGalleryVC dismissViewControllerAnimated:YES completion:NULL];
}

#pragma UIPhotoGalleryDelegate methods
- (void)photoGallery:(UIPhotoGalleryView *)photoGallery didTapAtIndex:(NSInteger)index {
}

- (UIPhotoGalleryDoubleTapHandler)photoGallery:(UIPhotoGalleryView *)photoGallery doubleTapHandlerAtIndex:(NSInteger)index {
    switch (photoGallery.galleryMode) {
        case UIPhotoGalleryModeImageLocal:
            return UIPhotoGalleryDoubleTapHandlerZoom;
            
        case UIPhotoGalleryModeImageRemote:
            return UIPhotoGalleryDoubleTapHandlerNone;
            
        default:
            return UIPhotoGalleryDoubleTapHandlerCustom;
    }
}

- (void)photoGallery:(UIPhotoGalleryView *)photoGallery didDoubleTapAtIndex:(NSInteger)index {
    DLog(@"invoke");
}

- (IBAction)btnFullscreenPressed:(UIButton *)sender {
    if (!photoGalleryVC) {
        photoGalleryVC = [[UIPhotoGalleryViewController alloc] init];
        photoGalleryVC.dataSource = self;
        photoGalleryVC.showStatusBar = YES;
    }
    
    if (self.navigationController)
        [self.navigationController pushViewController:photoGalleryVC animated:YES];
    else {
        photoGalleryVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:photoGalleryVC animated:YES completion:NULL];
    }
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

- (void)viewDidUnload {
    scrollView = nil;
    img1 = nil;
    img2 = nil;
    [super viewDidUnload];
}
@end
