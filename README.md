# UIPhotoGallery

**UIPhotoGallery** is a set of extended & customizable views to show Photo Gallery for iOS UIKit. This library contains 2 main components: **UIPhotoGalleryView** & **UIPhotoGalleryViewController**.

### Table of Contents
1. [DataSource, Delegate, Mode & Style](#datasource-delegate-mode--style)
	* [DataSource, Mode & Style](#datasource-mode--style)
	* [Delegate](#delegate)
2. [UIPhotoGalleryView](#uiphotogalleryview)
	* [Properties](#properties)
	* [Methods](#methods)
3. [UIPhotoGalleryViewController](#uiphotogalleryviewcontroller)
4. [Installation & Dependencies](installation--dependencies)
	* [Installation](#installation)
	* [Setup](#setup)
	* [Dependencies](#dependencies)
5. [Licences](#licences)

## DataSource, Delegate, Mode & Style

UIPhotoGallery is implemented in UITableView style, which uses ``dataSource** and **delegate** pointers to contruct UI components.

### DataSource, Mode & Style

To declare number of views showing in gallery:

	- (NSInteger)numberOfViewsInPhotoGallery:(UIPhotoGalleryView*)photoGallery;
	
To declare a view component in specific index:

	- (UIImage*)photoGallery:(UIPhotoGalleryView*)photoGallery localImageAtIndex:(NSInteger)index;
	- (NSURL*)photoGallery:(UIPhotoGalleryView*)photoGallery remoteImageURLAtIndex:(NSInteger)index;
	- (UIView*)photoGallery:(UIPhotoGalleryView*)photoGallery customViewAtIndex:(NSInteger)index;
	
At a moment, **_only 1_** method will be used to contruct view components for gallery, depends on UIPhotoGalleryView's **galleryMode** property. So far, there are 3 modes supported:

	UIPhotoGalleryModeImageLocal
    UIPhotoGalleryModeImageRemote
    UIPhotoGalleryModeCustomView

To declare a caption component in specific index:
	
	- (NSString*)photoGallery:(UIPhotoGalleryView*)photoGallery plainTextCaptionAtIndex:(NSInteger)index;
	- (NSAttributedString*)photoGallery:(UIPhotoGalleryView*)photoGallery attributedTextCaptionAtIndex:(NSInteger)index;
	- (UIView*)photoGallery:(UIPhotoGalleryView*)photoGallery customViewCaptionAtIndex:(NSInteger)index;

Similar to view component, **_only one_** caption contruction method is used at a moment to contruct caption for gallery item, depends on UIPhotoGalleryView's **captionStyle**, including 3 supported styles so far:

	UIPhotoCaptionStylePlainText
    UIPhotoCaptionStyleAttributedText
    UIPhotoCaptionStyleCustomView

### Delegate

So far, UIPhotoGallery provides 2 delegate methods:

	- (void)photoGallery:(UIPhotoGalleryView*)photoGallery didTapAtIndex:(NSInteger)index;
	- (void)photoGallery:(UIPhotoGalleryView*)photoGallery didDoubleTapAtIndex:(NSInteger)index;
	- (UIPhotoGalleryDoubleTapHandler)photoGallery:(UIPhotoGalleryView*)photoGallery doubleTapHandlerAtIndex:(NSInteger)index;

Use **photoGallery:didTapAtIndex:** method to handle single tap at gallery item.

Use **photoGallery:doubleTapHandlerAtIndex:** method to set default action for double tap gesture recognizer. Options including:

	UIPhotoGalleryDoubleTapHandlerNone
    UIPhotoGalleryDoubleTapHandlerZoom
    UIPhotoGalleryDoubleTapHandlerCustom
 
If this method return **UIPhotoGalleryDoubleTapHandlerZoom**, current photo item  will be zoomed at tapping position. If **UIPhotoGalleryDoubleTapHandlerCustom** returned, action will be dispatched to **photoGallery:didDoubleTapAtIndex:** if  implemented. Otherwise, if **UIPhotoGalleryDoubleTapHandlerNone** returned, nothing happens.

## UIPhotoGalleryView

### Properties

There are several properties that are helpful to quickly customize your gallery

	@property (nonatomic, assign) UIPhotoGalleryMode galleryMode;
	@property (nonatomic, assign) UIPhotoCaptionStyle captionStyle;
	@property (nonatomic, assign) BOOL peakSubView;
	@property (nonatomic, assign) BOOL verticalGallery;
	@property (nonatomic, assign) CGFloat subviewGap;
	@property (nonatomic, assign) NSInteger initialIndex;
	
As mentioned above, **galleryMode** and **captionStyle** are used to change gallery's mode (showing local images, remote images or custom views) and caption style (plain texts, attributed texts or custom views). By default, **galleryMode** is set to **UIPhotoGalleryModeLocalImage** and **captionStyle** is set to **UIPhotoCaptionStylePlainText**.

Use **peakSubView** to enable/disable gallery item's peak (draw items outside the UIPhotoGallery's frame). By default, this property is set to **NO**.

	vPhotoGallery.peakSubView = YES;

Use **verticalGallery** to set gallery's scroll direction to horizontal/vertical. By default, this property is set to **NO** (horizontal scrolling).

	vPhotoGallery.verticalGallery = YES;

Use **subviewGap** to adjust a blank gap between gallery items. By default, this property is set to **30.0**.

	vPhotoGallery.subviewGap = 50;

Use **initialIndex** to set the initial position when view is loaded. By default, this property is set to **0**.

	vPhotoGallery.initialIndex = 4;

**_Note:_** all of these properties may be set during runtime, your gallery will change right after setters are called without any additional methods calling.

### Methods

Comming along with properties to customize gallery's style, some helper methods are provided to control the scrolling of your gallery.

	- (void)setInitialIndex:(NSInteger)initialIndex animated:(BOOL)animation;
	- (BOOL)scrollToPage:(NSInteger)page animated:(BOOL)animation;
	- (BOOL)scrollToBesidePage:(NSInteger)delta animated:(BOOL)animation;
	
The method **setInitialIndex:animated:** is an alternative way to animate the initialization page setup. The default **initialIndex** property has no animation effect.

	[vPhotoGallery setInitialIndex:4 animated:YES];
	
	[vPhotoGallery setInitialIndex:4 animated:NO]; // Equivalent to vPhotoGallery.initialIndex = 4;

The method **scrollToBeSidePage** use a NSInteger **delta** param to scroll to the next or previous delta pages from current page.

	[vPhotoGallery scrollToBesidePage:1 animated:YES];
	[vPhotoGallery scrollToBesidePage:-2 animated:YES];
	
All validation of page index are done for you and returned **YES** if the index is valid and scrolling is made, otherwise **NO**.

## UIPhotoGalleryViewController

As an extension, UIPhotoGalleryViewController is created to help simplify your process of creating a view controller for gallery browsing. This view controller already included a **UIPhotoGalleryView** item named **vPhotoGallery**, which is initialized with default configurations.

There are same properties with **UIPhotoGalleryView** that you can use to set for your **vPhotoGallery**, except **delegate** (by default, gallery's delegate is handled by the view controller itself):

	@property (nonatomic, assign) id<UIPhotoGalleryDataSource> dataSource;
	@property (nonatomic, assign) UIPhotoGalleryMode galleryMode;
	@property (nonatomic, assign) UIPhotoCaptionStyle captionStyle;
	@property (nonatomic, assign) BOOL circleScroll;
	@property (nonatomic, assign) BOOL peakSubView;
	@property (nonatomic, assign) BOOL verticalGallery;
	@property (nonatomic, assign) CGFloat subviewGap;
	@property (nonatomic, assign) NSInteger initialIndex;

	@property (nonatomic, assign) BOOL showStatusBar;

An additional property is included, **showStatusBar** to force hiding status bar if application status bar is visible. **_Noted:_** if this property is set to **YES**, navigation bar will be hidden too.

Beside default dataSource methods from **UIPhotoGalleryDataSource**, there are 2 additional methods to setup top & bottom view for gallery view controller:
	
	- (UIView*)customTopViewForGalleryViewController:(UIPhotoGalleryViewController*)galleryViewController;
	- (UIView*)customBottomViewForGalleryViewController:(UIPhotoGalleryViewController*)galleryViewController;

If these methods are not implemented, **UIPhotoGalleryViewController** provide 2 default views for top & bottom for essential actions (dismiss view controller, scroll next & previous page).

If implemented, a custom view will be placed at top or bottom of view controller respectively.

Otherwise, if these methods are implemented and returned **nil**, the respective view will be hidden from view controller.

By default, for gallery delegate handling, when user single tap in gallery, top and bottom view will be hidden with animation.

## Installation & Dependencies

### Installation

For minimum requirement, add 4 following files to your project:

	UIPhotoGalleryView.h
	UIPhotoGalleryView.m
	UIPhotoItemView.h
	UIPhotoItemView.m

for **UIPhotoGalleryView** UI components & methods. The 2 additional files:

	UIPhotoGalleryViewController.h
	UIPhotoGalleryViewController.m

should be included only if you wants to use **UIPhotoGalleryViewController**.

### View setup

The **UIPhotoGalleryView** could be initialized using default method **initWithFrame:** or link the custom class from XIB file in following steps:

1. Go to your XIB file
2. Click on Files owner transparent box on the left
3. Open up your inspections tab(Third button on right in the View Section - in between Editor and Organizer)
4. Go to your identity Inspector(3rd from the left) underneath the editor organizer view tab.
5. Fix the custom class - Class option to whatever class you want it to respond to.

The **dataSource** and **delegate** can also be linked in Interface Builder.

### Depenencies

The project uses [**SDWebImage**](https://github.com/rs/SDWebImage) as default image loading and displaying. Please follow [its installation instructions](https://github.com/rs/SDWebImage#installation) to setup the project or customize your image loading methods inside **UIRemotePhotoItem** class implementation (_UIPhotoItemView.m_)

## Licences

All source code is licensed under the [MIT Licensed](http://opensource.org/licenses/MIT)

	Copyright (c) 2013 Ethan Nguyen <ethan@vinova.sg>
	 
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is furnished
	to do so, subject to the following conditions:
	 
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
	 
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
