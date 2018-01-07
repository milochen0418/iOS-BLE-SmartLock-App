//
//  BeLockOwnerViewController.m
//  SmartLock
//
//  Created by Milo Chen on 2/17/15.
//  Copyright (c) 2015 Milo Chen. All rights reserved.
//

#import "BeLockOwnerViewController.h"
#import "MBProgressHUD.h"

@interface BeLockOwnerViewController () <MBProgressHUDDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *mLockIconImgView;
@property (strong, nonatomic) IBOutlet UIImageView *mLockWordImgView;
@property (strong, nonatomic) IBOutlet UIButton *mBeLockOwnerBtn;
@property (nonatomic,strong) MBProgressHUD * mHud;
@end

@implementation BeLockOwnerViewController
@synthesize mHud;
@synthesize mBeLockOwnerBtn,mLockIconImgView,mLockWordImgView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mBeLockOwnerBtn.layer.borderColor = [[UIColor blackColor] CGColor];
    mBeLockOwnerBtn.alpha = 0.75;
    
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



static bool isCurrentNavBarInHidden = NO;
- (void)viewWillAppear:(BOOL)animated    // Called when the view is about to made visible. Default does nothing
{
    [self.navigationController setNavigationBarHidden:isCurrentNavBarInHidden];
    UIView *topBarView = self.navigationController.navigationBar.viewForBaselineLayout;
    topBarView.alpha = 0.0;
    mBeLockOwnerBtn.alpha = 0.0;
    mLockIconImgView.alpha = 0.0;
    mLockWordImgView.alpha = 0.0;
    
    [UIView animateWithDuration:0.5 animations:^{
        //[self.navigationController setNavigationBarHidden:isCurrentNavBarInHidden];
        topBarView.alpha = 0.75;
    }
    completion:^(BOOL finished){
        [UIView animateWithDuration:1.0 animations:^{
            //mTakeItBtn.alpha = 0.65;
            mBeLockOwnerBtn.alpha = 0.65;
        } completion:^(BOOL finished){
        }];
    }];
    
    [UIView animateWithDuration:3.0 animations:^{
        //mLockWordImgView.alpha = 1.0;
        mLockWordImgView.alpha = 0.75;
        //mLockIconImgView.alpha = 1.0;
        mLockIconImgView.alpha = 0.75;
        //mKeyReceiveImgView.alpha = 1.0;
        //mKeyImgView.alpha = 1.0;
    } completion:^(BOOL finished){
    }];
    
    
    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    
    
}



-(void) showHudWithStr:(NSString*)str andSelector:(SEL)method{
    mHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:mHud];
    mHud.delegate = self;
    mHud.labelText = str;
    [mHud showWhileExecuting:method onTarget:self withObject:nil animated:YES];
    return;
}


- (IBAction)clickToBeLockOwner:(id)sender {
    //[self showHudWithStr:@"Take keying"];
    //[[self navigationController ] popViewControllerAnimated:YES];
    [self showHudWithStr:@"Get owner..." andSelector:@selector(BeLockOwnerTask)];
}


-(void) BeLockOwnerTask{
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
    mHud.labelText = @"Owner Ready";
    sleep(2);
    
}



#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    
    [mHud removeFromSuperview];
    mHud = nil;
}




@end
