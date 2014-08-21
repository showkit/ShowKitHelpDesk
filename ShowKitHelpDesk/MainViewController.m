//
//  ViewController.m
//  ShowKitHelpDesk
//
//  Created by Anthony Kelani on 7/16/14.
//  Copyright (c) 2014 Anthony Kelani. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController () {
    BOOL drawing;
}

@end

@implementation MainViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"ring" withExtension:@"wav"];
    m_AVPlayer= [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
    [m_AVPlayer setNumberOfLoops:-1];
    
    CALayer *videoShadowLayer = self.mainVideoView.layer;
    videoShadowLayer.masksToBounds = NO;
    videoShadowLayer.shadowOffset = CGSizeMake(0.0, 5.0);
    videoShadowLayer.shadowRadius = 5.0;
    videoShadowLayer.shadowOpacity = 0.6;
    
    CALayer *toolbarShadowLayer = self.mainToolbarView.layer;
    toolbarShadowLayer.masksToBounds = NO;
    toolbarShadowLayer.shadowOffset = CGSizeMake(0.0, -2.5);
    toolbarShadowLayer.shadowRadius = 2.5;
    toolbarShadowLayer.shadowOpacity = 0.6;
    
    drawing = NO;
    
    
    [[BButton appearance] setButtonCornerRadius:[NSNumber numberWithFloat:5.0f]];

    [self.answerButton setStyle:BButtonStyleBootstrapV3];
    [self.answerButton setType:BButtonTypeSuccess];
    
    [self.logoutButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.logoutButton setStyle:BButtonStyleBootstrapV3];
    [self.logoutButton setType:BButtonTypeInverse];
    
    [self.muteButton setStyle:BButtonStyleBootstrapV3];
    [self.muteButton setType:BButtonTypeSuccess];
    [self.muteButton addAwesomeIcon:FAVolumeOff beforeTitle:YES];
    
    [self.videoButton setStyle:BButtonStyleBootstrapV3];
    [self.videoButton setType:BButtonTypeSuccess];
    [self.videoButton addAwesomeIcon:FAVideoCamera beforeTitle:YES];
    
    [self.drawButton setStyle:BButtonStyleBootstrapV3];
    [self.drawButton setType:BButtonTypeDanger];
    [self.drawButton addAwesomeIcon:FAPencil beforeTitle:YES];
    
    
    //ShowKit
    
    [ShowKit setConfig:@{
                         SHKVideoLocalPreviewModeKey: SHKVideoLocalPreviewEnabled,
                         SHKMainDisplayViewKey: self.mainVideoView,
                         SHKVideoDecodeDeviceKey: SHKVideoDecodeDeviceSoftware
                         }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shkConnectionStatusChanged:)
                                                 name:SHKConnectionStatusChangedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(remoteClientStatusChanged:)
                                                 name:SHKRemoteClientStateChangedNotification
                                               object:nil];
    
}

- (void) shkConnectionStatusChanged: (NSNotification*) notification
{
    SHKNotification* obj = [notification object];
    
    if([(NSString*)obj.Value isEqualToString:SHKConnectionStatusCallIncoming])
    {
        [SVProgressHUD showWithStatus:@"Incoming call..." maskType:SVProgressHUDMaskTypeNone];
        [self.inCallButtonsView setHidden:NO];
        
        if([UIApplication sharedApplication].applicationState  == UIApplicationStateBackground)
        {
            //if the application is in the background, show the user a localnotification
            UILocalNotification* ln = [[UILocalNotification alloc] init];
            ln.fireDate = [NSDate date];
            ln.alertBody = [NSString stringWithFormat:@"Incoming call from %@", obj.UserObject];
            ln.soundName = @"ring.wav";
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            [[UIApplication sharedApplication] scheduleLocalNotification:ln];
        } else {
            //otherwise lets play a ringing tone.
            [self->m_AVPlayer play];
        }
        
    }
    else if ([(NSString*)obj.Value isEqualToString:SHKConnectionStatusInCall])
    {
        [SVProgressHUD showSuccessWithStatus:@"Connected"];
        [SVProgressHUD dismiss];
        
        [self.mainLogoImageView setHidden:YES];
        [self.answerButton setTitle:@"Hangup" forState:UIControlStateNormal];
        [self.answerButton setType:BButtonTypeDanger];
    }
    else if ([(NSString*)obj.Value isEqualToString:SHKConnectionStatusCallTerminated])
    {
        [SVProgressHUD showSuccessWithStatus:@"Call Ended"];
        [SVProgressHUD dismiss];
        
        [self.mainLogoImageView setHidden:NO];
        [self.answerButton setTitle:@"Answer" forState:UIControlStateNormal];
        [self.answerButton setStyle:BButtonStyleBootstrapV3];
        [self.answerButton setType:BButtonTypeSuccess];
        [self.inCallButtonsView setHidden:YES];
    }
    else if ([(NSString*)obj.Value isEqualToString:SHKConnectionStatusCallOutgoing])
    {
    }
    else if([(NSString*)obj.Value isEqualToString:SHKConnectionStatusNotConnected])
    {
        [SVProgressHUD dismiss];
    }
    else if ([(NSString*)obj.Value isEqualToString:SHKConnectionStatusCallFailed]) {
    }
}

- (void) remoteClientStatusChanged: (NSNotification*) notification
{
    SHKNotification* obj = [notification object] ;
    

    if([obj.Key isEqualToString:SHKRemoteClientDeviceOrientationKey])
    {
    }
    else if([obj.Key isEqualToString:SHKRemoteClientGestureStateKey])
    {
    }
    else if([obj.Key isEqualToString:SHKRemoteClientVideoInputKey])
    {
        if([(NSString*)obj.Value isEqualToString:SHKRemoteClientVideoInputScreen])
        {
            NSLog(@"Screen mode enabled!");
            [ShowKit setState:SHKVideoScaleModeFit forKey: SHKVideoScaleModeKey];
            [ShowKit setState:SHKGestureCaptureLocalIndicatorsOn forKey:SHKGestureCaptureLocalIndicatorsModeKey];
            if (![[ShowKit getStateForKey:SHKGestureCaptureModeKey] isEqualToString:SHKGestureCaptureModeBroadcast]) {
                [ShowKit setState:SHKGestureCaptureModeBroadcast forKey:SHKGestureCaptureModeKey];
            }
            
        } else {
            [ShowKit setState:SHKVideoScaleModeFill forKey: SHKVideoScaleModeKey];
            if (![[ShowKit getStateForKey:SHKGestureCaptureModeKey] isEqualToString:SHKGestureCaptureModeOff]) {
                [ShowKit setState:SHKGestureCaptureLocalIndicatorsOff forKey:SHKGestureCaptureLocalIndicatorsModeKey];
            }
        }
    }
    else if([obj.Key isEqualToString:SHKRemoteClientVideoStateKey])
    {
    }
    else if([obj.Key isEqualToString:SHKRemoteClientAudioStateKey])
    {
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)answerButtonTapped:(id)sender {
    
    if([m_AVPlayer isPlaying])
    {
        [m_AVPlayer stop];
    }
    
    NSString* connectionStatus = [ShowKit getStateForKey:SHKConnectionStatusKey];
    if ([connectionStatus isEqualToString:SHKConnectionStatusInCall]) {
        [ShowKit hangupCall];
        [SVProgressHUD showWithStatus:@"Disconnecting..." maskType:SVProgressHUDMaskTypeNone];
    } else {
        [ShowKit acceptCall];
    }
}

- (IBAction)muteButtonTapped:(id)sender {
    
    NSString* audio_state = (NSString*)[ShowKit getStateForKey: SHKAudioInputModeKey];
    if([audio_state isEqualToString: SHKAudioInputModeRecording]) {
        [ShowKit setState: SHKAudioInputModeMuted forKey: SHKAudioInputModeKey];
        [self.muteButton setType:BButtonTypeDanger];

    } else {
        [ShowKit setState: SHKAudioInputModeRecording forKey: SHKAudioInputModeKey];
        [self.muteButton setType:BButtonTypeSuccess];
    }
}

- (IBAction)videoButtonTapped:(id)sender {
    NSString* video_state = (NSString*)[ShowKit getStateForKey: SHKVideoInputDeviceKey];
    if([video_state isEqualToString: SHKVideoInputDeviceFrontCamera] || [video_state isEqualToString: SHKVideoInputDeviceBackCamera]) {
        [ShowKit setState: SHKVideoInputDeviceNone forKey: SHKVideoInputDeviceKey];
        [self.videoButton setType:BButtonTypeDanger];
    } else {
        [ShowKit setState: SHKVideoInputDeviceFrontCamera forKey: SHKVideoInputDeviceKey];
        [self.videoButton setType:BButtonTypeSuccess];
    }
}

- (IBAction)drawButtonTapped:(id)sender {
    if (drawing) {
        drawing = NO;
        [ShowKit setState:SHKDrawModeOff forKey:SHKDrawMode];
        [self.drawButton setType:BButtonTypeDanger];
    } else {
        drawing = YES;
        [ShowKit setState:SHKDrawModeOn forKey:SHKDrawMode];
        [self.drawButton setType:BButtonTypeSuccess];
    }
}

- (IBAction)logoutButtonTapped:(id)sender {
    
    if([m_AVPlayer isPlaying])
    {
        [m_AVPlayer stop];
    }
    
    NSString* login_state = (NSString*)[ShowKit getStateForKey: SHKConnectionStatusKey];
    if ([login_state isEqualToString:SHKConnectionStatusLoggedIn]) {
        [SVProgressHUD showWithStatus:@"Logging out..." maskType:SVProgressHUDMaskTypeBlack];
        [ShowKit logout];
        [self.logoutButton setTitle:@"Login" forState:UIControlStateNormal];
        [self.logoutButton setStyle:BButtonStyleBootstrapV3];
        [self.logoutButton setType:BButtonTypeInverse];
    } else {
        UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"ShowKit Login" message:@"Log in with your ShowKit Agent credentials" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
        loginAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        [loginAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UITextField *usernameField = [alertView textFieldAtIndex:0];
        UITextField *passwordField = [alertView textFieldAtIndex:1];
        
        if (usernameField.text.length > 0 && passwordField.text.length > 0) {
            [SVProgressHUD showWithStatus:@"Logging in..." maskType:SVProgressHUDMaskTypeBlack];
            [ShowKit login:usernameField.text password:passwordField.text withCompletionBlock:^(NSString *const connectionStatus) {
                if ([connectionStatus isEqualToString:SHKConnectionStatusLoggedIn]) {
                    [self.logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
                    [self.logoutButton setStyle:BButtonStyleBootstrapV3];
                    [self.logoutButton setType:BButtonTypeDanger];
                    [SVProgressHUD dismiss];
                } else {
                    [SVProgressHUD dismiss];
                    // The login failed.
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Login Failed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                }
            }];
        } else {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Must enter username and password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [errorAlert show];
        }
    }
}

- (void) showFailure {
    [SVProgressHUD dismiss];
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:nil message:@"Support is currently unavailable. Please contact support at another time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [message show];
}
@end
