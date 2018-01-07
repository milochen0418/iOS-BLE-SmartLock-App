//
//  GiveAKeyViewController.m
//  SmartLock
//
//  Created by Milo Chen on 2/20/15.
//  Copyright (c) 2015 Milo Chen. All rights reserved.
//

#import "GiveAKeyViewController.h"
#import "MBProgressHUD.h"
@interface GiveAKeyViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate,MBProgressHUDDelegate>
@property (strong, nonatomic) IBOutlet UITextField *mTypeNameTextField;
@property (strong, nonatomic) IBOutlet UIButton *mGiveAKeyBtn;
@property (strong, nonatomic) IBOutlet UIImageView *mTakePictureImg;
@property (strong, nonatomic) IBOutlet UIImageView *mPhotoImgView;
@property (nonatomic,strong)  UIImagePickerController * mImgPicker;
@property (nonatomic,strong) UIGestureRecognizer *mTapper;

@property (nonatomic,strong) MBProgressHUD *mHud;
@end

@implementation GiveAKeyViewController
@synthesize mTypeNameTextField,mTapper;
@synthesize mGiveAKeyBtn;
@synthesize mTakePictureImg;
@synthesize mPhotoImgView;
@synthesize mImgPicker;
@synthesize mHud;

- (IBAction)clickToGiveAKey:(id)sender {
    [self onStartGiveAKey];
}

-(void) onStartGiveAKey {
    [self showHudWithStr:@"start give key..." andSelector:@selector(GiveAKeyTask)];
}


-(void) showHudWithStr:(NSString*)str andSelector:(SEL)method{
    mHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:mHud];
    mHud.delegate = self;
    mHud.labelText = str;
    [mHud showWhileExecuting:method onTarget:self withObject:nil animated:YES];
    return;
}




-(void) GiveAKeyTask{
    //@selector(myTask);
    sleep(3);
    [[self navigationController ] popViewControllerAnimated:YES];
    
    __block UIImageView *imageView;
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
        imageView = [[UIImageView alloc] initWithImage:image];
    });
    mHud.customView = imageView;
    mHud.mode = MBProgressHUDModeCustomView;
    mHud.labelText = @"Key is given";
    sleep(2);
    
}


static bool isCurrentNavBarInHidden = NO;
- (void)viewWillAppear:(BOOL)animated    // Called when the view is about to made visible. Default does nothing
{
    [self.navigationController setNavigationBarHidden:isCurrentNavBarInHidden];
    UIView *topBarView = self.navigationController.navigationBar.viewForBaselineLayout;
    topBarView.alpha = 0.0;
    mTypeNameTextField.alpha = 0;
    mGiveAKeyBtn.alpha = 0;
    mTakePictureImg.alpha = 0;
    mPhotoImgView.alpha = 0;
    [UIView animateWithDuration:0.7 animations:^{
        topBarView.alpha = 0.75;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.3 animations:^{
            mTypeNameTextField.alpha = 0.75;
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.3 animations:^{
                mTakePictureImg.alpha = 0.75;
                mPhotoImgView.alpha = 0.00;
                if(mPhotoImgView.image != nil) {
                    mPhotoImgView.alpha = 0.0;
                }
                else {
                    mPhotoImgView.alpha = 0.75;
                }
                
            } completion:^(BOOL finished){
                [UIView animateWithDuration:0.3 animations:^{
                    mGiveAKeyBtn.alpha = 0.75;
                    if(mPhotoImgView.image != nil) {
                        mPhotoImgView.alpha = 0.0;
                    }
                } completion:^(BOOL finished){
                    
                }];
                if(mPhotoImgView.image != nil) {
                    [UIView animateWithDuration:3.6 animations:^{
                        mPhotoImgView.alpha = 1.0;
                    } completion:^(BOOL finished){
                        
                    }];
                }
                
            }];
            
        }];
        
    }];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mTapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    mTapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:mTapper];
    
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clickToTakePicture:(id)sender {
    NSLog(@"Take Picture");
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    mImgPicker = picker;
    mImgPicker.delegate = self;
    mImgPicker.allowsEditing = YES;
    mImgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    //self.imageView.image = chosenImage;
    self.mPhotoImgView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"mTypeNameTextField.text is %@", mTypeNameTextField.text);
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    
    [mHud removeFromSuperview];
    mHud = nil;
}





@end
