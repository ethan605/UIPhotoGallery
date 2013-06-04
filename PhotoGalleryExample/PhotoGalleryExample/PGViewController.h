//
//  PGViewController.h
//  PhotoGalleryExample
//
//  Created by Ethan Nguyen on 5/24/13.
//
//

#import <UIKit/UIKit.h>
#import "UIPhotoGalleryView.h"

@class UIPhotoGalleryViewController;

@interface PGViewController : UIViewController<UIPhotoGalleryDataSource, UIPhotoGalleryDelegate> {
    IBOutlet UIPhotoGalleryView *vPhotoGallery;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *img1;
    IBOutlet UIImageView *img2;
    
    UIPhotoGalleryViewController *photoGalleryVC;
}

- (IBAction)btnFullscreenPressed:(UIButton *)sender;
- (IBAction)segGalleryModeChanged:(UISegmentedControl *)sender;

@end
