//
//  ViewController.h
//  ShowKitHelpDesk
//
//  Created by Anthony Kelani on 7/16/14.
//  Copyright (c) 2014 Anthony Kelani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ShowKit/ShowKit.h>
#import "BButton.h"
#import "SVProgressHUD.h"

@interface MainViewController : UIViewController <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *mainVideoView;
@property (weak, nonatomic) IBOutlet UIView *mainToolbarView;
@property (weak, nonatomic) IBOutlet UIView *inCallButtonsView;
@property (weak, nonatomic) IBOutlet UIImageView *mainLogoImageView;
@property (weak, nonatomic) IBOutlet BButton *answerButton;
@property (weak, nonatomic) IBOutlet BButton *logoutButton;
@property (weak, nonatomic) IBOutlet BButton *muteButton;
@property (weak, nonatomic) IBOutlet BButton *videoButton;
@property (weak, nonatomic) IBOutlet BButton *drawButton;

- (IBAction)answerButtonTapped:(id)sender;
- (IBAction)muteButtonTapped:(id)sender;
- (IBAction)videoButtonTapped:(id)sender;
- (IBAction)drawButtonTapped:(id)sender;
- (IBAction)logoutButtonTapped:(id)sender;

@end

