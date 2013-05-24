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
    
    UIPhotoGalleryViewController *photoGalleryVC;
}

- (IBAction)btnFullscreenPressed:(UIButton *)sender;
- (IBAction)segGalleryModeChanged:(UISegmentedControl *)sender;

@end
