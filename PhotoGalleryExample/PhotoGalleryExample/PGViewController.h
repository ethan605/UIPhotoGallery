//
//  PGViewController.h
//  PhotoGalleryExample
//
//  Created by Ethan Nguyen on 5/24/13.
//
//

#import <UIKit/UIKit.h>

@class UIPhotoGalleryView;

@interface PGViewController : UIViewController {
    IBOutlet UIPhotoGalleryView *vPhotoGallery;
}

- (IBAction)segGalleryModeChanged:(UISegmentedControl *)sender;

@end
