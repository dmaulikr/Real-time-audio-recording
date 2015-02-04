//
//  ViewController.m
//  AudioRecorder
//
//  Created by Pardeep on 02/02/15.
//
//

#import "ViewController.h"
#import "IosAudioController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface ViewController ()

@end

@implementation ViewController

#define KFacebookLoginErrorMessage @"Facebook Login Error"

#pragma mark - View's life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction methods
- (IBAction)btnStartAction:(id)sender {
    [iosAudio start];
}

- (IBAction)btnStopAction:(id)sender {
    [iosAudio stop];
}

- (IBAction)btnFacebookAction:(id)sender {
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended)
    {
        [self getUserFacebookBasicInfo];
    }
    else {
        [FBSession openActiveSessionWithPublishPermissions:@[@"public_profile", @"email"]
                                           defaultAudience:FBSessionDefaultAudienceFriends
                                              allowLoginUI:YES
                                         completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             if (!error && (state == FBSessionStateOpen || state == FBSessionStateOpenTokenExtended)) {
                 [self getUserFacebookBasicInfo];
             } else if (error) {
                 [self handleError:error];
             }
         }];
    }
}

#pragma mark - User defined methods
//Get user's info from facebook
- (void)getUserFacebookBasicInfo
{    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            [self handleError:error];
        } else {
            if (result) {
                NSMutableDictionary *resultDict = (NSMutableDictionary *)result;
                [self updateView:resultDict];
            }
        }
    }];
}

//Handle the facebook seesions' error
- (void)handleError:(NSError *)error
{
    NSString *alertText;
    
    if ([FBErrorUtility shouldNotifyUserForError:error] == YES)
    {
        alertText = [FBErrorUtility userMessageForError:error];
    } else
    {
        if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
            alertText = [FBErrorUtility userMessageForError:error];
        } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
            alertText = @"There is some issue while creating session";
        } else {
            NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
            
            NSString *alertMessage = NSLocalizedString(@"SignInViewFbLoginViewUnknownErrorMessage", @"");
            alertText = [NSString stringWithFormat:@"%@ : %@",alertMessage ,[errorInformation objectForKey:@"message"]];
        }
    }
    
    [self showAlertWithTitle:KFacebookLoginErrorMessage withMessage:alertText];
    // Clear token
    [FBSession.activeSession closeAndClearTokenInformation];
}

//Update the text field's values
-(void)updateView:(NSMutableDictionary*)dictData {
    txtFirstName.text = [dictData valueForKey:@"first_name"];
    txtLastName.text = [dictData valueForKey:@"last_name"];
    txtEmailAddress.text = [dictData valueForKey:@"email"];
}

//Show the alert
-(void)showAlertWithTitle:(NSString *)title withMessage:(NSString *)message{
    [[[UIAlertView alloc]initWithTitle:title
                               message:message
                              delegate:nil
                     cancelButtonTitle:@"Ok"
                     otherButtonTitles: nil] show];
}

@end