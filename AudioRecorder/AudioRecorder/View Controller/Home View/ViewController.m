//
//  ViewController.m
//  AudioRecorder
//
//  Created by Pardeep on 02/02/15.
//
//

#import "ViewController.h"
#import "AudioRecorderViewController.h"

#import <FacebookSDK/FacebookSDK.h>

@interface ViewController ()

@end

@implementation ViewController

#define KFacebookLoginErrorMessage @"Facebook Login Error"

#pragma mark - View's life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self setUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User defined methods
-(void)setUI
{
    [txtFirstName setLeftViewMode:UITextFieldViewModeAlways];
    [txtFirstName setLeftView: [self leftViewForTextFieldWithImage:@"username"]];
    
    [txtLastName setLeftViewMode:UITextFieldViewModeAlways];
    [txtLastName setLeftView: [self leftViewForTextFieldWithImage:@"lock_white"]];
}

#pragma mark - IBAction methods
- (IBAction)btnFacebookAction:(id)sender {
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended)
    {
        [self getUserFacebookBasicInfo];
    }
    else {//,@"user_about_me"
        [FBSession openActiveSessionWithPublishPermissions:@[@"public_profile"]
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
- (IBAction)btnNextAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AudioRecorderViewController *objAudioRecorderViewController = (AudioRecorderViewController*) [storyboard instantiateViewControllerWithIdentifier:@"AudioRecorderViewControllerIdentifier"];
    [self.navigationController pushViewController:objAudioRecorderViewController animated:YES];
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
            if (alertText == nil || [alertText isEqualToString:@""])
                alertText = @"User cancelled the operation";
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

[UIView animateWithDuration:1.0f
                      delay:0.0f
                    options:UIViewAnimationOptionCurveLinear
                 animations:^{
                         [btnNext setFrame:CGRectMake(btnNext.frame.origin.x, 230, btnNext.frame.size.width, btnNext.frame.size.height)];                     
                 }completion:nil];

}

//Show the alert
-(void)showAlertWithTitle:(NSString *)title withMessage:(NSString *)message{
    [[[UIAlertView alloc]initWithTitle:title
                               message:message
                              delegate:nil
                     cancelButtonTitle:@"Ok"
                     otherButtonTitles: nil] show];
}

#pragma mark - Helper methods
- (UIImageView *)leftViewForTextFieldWithImage:(NSString *)imageName {
    
    UIImage *imageForLeftMode = [UIImage imageNamed:imageName];
    
    UIImageView *imgViewLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    [imgViewLeft setImage:imageForLeftMode];
    [imgViewLeft setContentMode:UIViewContentModeCenter];
    
    return imgViewLeft;
}
@end