//
//  NearLockViewController.m
//  SmartLock
//
//  Created by Milo Chen on 2/19/15.
//  Copyright (c) 2015 Milo Chen. All rights reserved.
//

#import "NearLockViewController.h"
#import "MBProgressHUD.h"
@interface NearLockViewController () <MBProgressHUDDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *mLockIconImgView;
@property (strong, nonatomic) IBOutlet UIImageView *mLockWordImgView;
@property (strong, nonatomic) IBOutlet UIButton *mLockUnlockBtn;
@property (strong, nonatomic) IBOutlet UIImageView *mLockUnlockImgView;
@property (strong, nonatomic) IBOutlet UIButton *mSettingBtn;
@property (nonatomic,strong) MBProgressHUD * mHud;
@property (nonatomic) bool mIsUnlock;

@end

@implementation NearLockViewController
@synthesize mHud;
@synthesize mLockIconImgView,mLockWordImgView,mLockUnlockBtn,mLockUnlockImgView,mSettingBtn;
@synthesize mIsUnlock;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mLockUnlockBtn.layer.borderColor = [[UIColor blackColor] CGColor];
    mLockUnlockBtn.alpha = 0.75;
    
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    
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



- (IBAction)clickToFeedbackUnlock:(id)sender {
    [self onFeedbackUnlock];
}
- (IBAction)clickToFeedbackLock:(id)sender {
        [self onFeedbackLock];
}
- (IBAction)clickToOpenSetting:(id)sender {
    
}

-(void) onFeedbackLock {
    NSLog(@"onFeedbackLock");
    [self showHudWithStr:@"Lock" andSelector:@selector(lockStatusTask)];
    mIsUnlock = NO;
}

-(void) onFeedbackUnlock {
    NSLog(@"onFeedbackUnlock");
    [self showHudWithStr:@"Unlock" andSelector:@selector(unlockStatusTask)];
    mIsUnlock = YES;
}

-(void) requestLock {
    NSLog(@"requestLock");
    [self showHudWithStr:@"request lock" andSelector:@selector(requestLockTask)];
}
-(void) requestUnlock {
    NSLog(@"requestUnlock");
    [self showHudWithStr:@"request unlock" andSelector:@selector(requestUnlockTask)];
}

-(void) requestGetLockStatus {
    NSLog(@"requestGetLockStatus");
    [self showHudWithStr:@"request status" andSelector:@selector(requestGetLockStatusTask)];
}

-(void) requestGetLockStatusTask {
    NSLog(@"requestGetLockStatusTask");
    sleep(1);
    //[self onFeedbackLock];
    [self onFeedbackLock];
}


-(void) requestLockTask {
    NSLog(@"requestLockTask");
    sleep(1);
    [self onFeedbackLock];
}

-(void) requestUnlockTask {
    NSLog(@"requestUnlockTask");
    sleep(1);
    [self onFeedbackUnlock];
}



-(void) lockStatusTask {
    sleep(1);
    [self requestGuiShowLockStatus];

}

-(void) unlockStatusTask {
    sleep(1);
    [self requestGuiShowUnlockStatus];
}

-(void) requestGuiShowLockStatus {
    //self.mLockUnlockImgView.image = [UIImage imageNamed:@"lock_status.jpg"];
    self.mLockUnlockImgView.image = [UIImage imageNamed:@"black_lock_img.jpg"];
    self.mLockUnlockImgView.alpha = 0.75;
    [self.mLockUnlockBtn setTitle:@"Unlock" forState:UIControlStateNormal];
}

-(void) requestGuiShowUnlockStatus {
    //self.mLockUnlockImgView.image = [UIImage imageNamed:@"unlock_status.jpg"];
    self.mLockUnlockImgView.image = [UIImage imageNamed:@"black_unlock_img.jpg"];
    self.mLockUnlockImgView.alpha = 0.75;
    [self.mLockUnlockBtn setTitle:@"Lock" forState:UIControlStateNormal];
}


-(void) showHudWithStr:(NSString*)str andSelector:(SEL)method{
    mHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:mHud];
    mHud.delegate = self;
    mHud.labelText = str;
    [mHud showWhileExecuting:method onTarget:self withObject:nil animated:YES];
    return;
}



- (IBAction)clickToLockUnlock:(id)sender {
    if(mIsUnlock) {
        [self requestLock];
    }
    else {
        [self requestUnlock];
    }
}


- (IBAction)clickToNotFoound:(id)sender {
    [self onNotFound];
}

-(void) onNotFound {
    NSLog(@"Not Found");
    [self.navigationController popViewControllerAnimated:YES];
    
}

static bool isCurrentNavBarInHidden = YES;
- (void)viewWillAppear:(BOOL)animated    // Called when the view is about to made visible. Default does nothing
{
    [self.navigationController setNavigationBarHidden:isCurrentNavBarInHidden];
    UIView *topBarView = self.navigationController.navigationBar.viewForBaselineLayout;
    topBarView.alpha = 0.0;
    mLockIconImgView.alpha = 0;
    mLockWordImgView.alpha = 0;
    mLockUnlockImgView.alpha = 0;
    mLockUnlockBtn.alpha = 0;
    mSettingBtn.alpha = 0;


    [UIView animateWithDuration:0.7 animations:^{
        mLockWordImgView.alpha = 0.75;
        mLockIconImgView.alpha = 0.75;
    }
    completion:^(BOOL finished){
        [UIView animateWithDuration:0.3 animations:^{
            mLockUnlockImgView.alpha = 0.75;
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.3 animations:^{
                mLockUnlockBtn.alpha = 0.75;
            } completion:^(BOOL finished){
                [UIView animateWithDuration:0.3 animations:^{
                    mSettingBtn.alpha = 0.75;
                } completion:^(BOOL finished){
                    
                }];
            }];
        }];
    }];
    
    [self requestGetLockStatus];
    
}






#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [mHud removeFromSuperview];
    mHud = nil;
}



@end
