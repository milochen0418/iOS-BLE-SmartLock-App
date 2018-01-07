//
//  ReceiveKeyViewController.m
//  SmartLock
//
//  Created by Milo Chen on 2/16/15.
//  Copyright (c) 2015 Milo Chen. All rights reserved.
//

#import "ReceiveKeyViewController.h"
#import "MBProgressHud.h"
#import <AudioToolbox/AudioToolbox.h>


@interface ReceiveKeyViewController () <MBProgressHUDDelegate>
@property (strong, nonatomic) IBOutlet UIButton *mTakeItBtn;
@property (strong, nonatomic) IBOutlet UIImageView *mKeyReceiveImgView;
@property (strong, nonatomic) IBOutlet UIImageView *mKeyImgView;
@property (nonatomic,strong) MBProgressHUD * mHud;
@end



@implementation ReceiveKeyViewController
@synthesize mHud;
@synthesize mTakeItBtn;
@synthesize mKeyReceiveImgView;
@synthesize mKeyImgView;

- (void)viewDidLoad {
    NSLog(@"ReceiveKeyViewController viewDidLoad ");    
    [super viewDidLoad];

    
    
    mTakeItBtn.layer.borderColor = [[UIColor blackColor] CGColor];
    mTakeItBtn.alpha = 0.75;


}


- (IBAction)clickToTakeIt:(id)sender {
    //[self showHudWithStr:@"Take keying"];
    //[[self navigationController ] popViewControllerAnimated:YES];
    [self showHudWithStr:@"Receiving key..." andSelector:@selector(TakeKeyingTask)];
}


-(void) TakeKeyingTask{
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
    mHud.labelText = @"Receive OK";
    sleep(2);
    
}



- (void)myMixedTask {
    /*
    // Indeterminate mode
    sleep(2);
    // Switch to determinate mode
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.labelText = @"Progress";
    float progress = 0.0f;
    while (progress < 1.0f)
    {
        progress += 0.01f;
        HUD.progress = progress;
        usleep(50000);
    }
    // Back to indeterminate mode
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Cleaning up";
    */
    
    /*
    sleep(2);
    // UIImageView is a UIKit class, we have to initialize it on the main thread
    __block UIImageView *imageView;
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
        imageView = [[UIImageView alloc] initWithImage:image];
    });
    HUD.customView = [imageView autorelease];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = @"Completed";
    sleep(2);
     */
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

static bool isCurrentNavBarInHidden = NO;
- (void)viewWillAppear:(BOOL)animated    // Called when the view is about to made visible. Default does nothing
{
    [self.navigationController setNavigationBarHidden:isCurrentNavBarInHidden];
    UIView *topBarView = self.navigationController.navigationBar.viewForBaselineLayout;
    topBarView.alpha = 0.0;
    mTakeItBtn.alpha = 0.0;
    mKeyImgView.alpha = 0.0;
    mKeyReceiveImgView.alpha = 0.0;
    [UIView animateWithDuration:2.0 animations:^{
        //[self.navigationController setNavigationBarHidden:isCurrentNavBarInHidden];
        topBarView.alpha = 0.75;
    }
    completion:^(BOOL finished){
        [UIView animateWithDuration:2.0 animations:^{
            mTakeItBtn.alpha = 0.65;
        } completion:^(BOOL finished){
        }];
        
    }];
    
    [UIView animateWithDuration:6.0 animations:^{
        mKeyReceiveImgView.alpha = 0.75;
        mKeyImgView.alpha = 0.75;
    } completion:^(BOOL finished){
    }];
    
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    

    
}

-(void) viewDidAppear:(BOOL)animated {
    [self showHudWithStr:@"Sercuity Channel Building" andSelector:@selector(SercuityChannelTask)];
}

-(void) safeChannel {
    sleep(1);
    dispatch_async(dispatch_get_main_queue(),^{
        [self showHudWithStr:@"Channel Ready" andSelector:@selector(safeChannelOK)];
    });
}
-(void) safeChannelOK {

}


-(void) SercuityChannelTask{
    //@selector(myTask);
    sleep(2);
    //[[self navigationController ] popViewControllerAnimated:YES];
    
    __block UIImageView *imageView;
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
        imageView = [[UIImageView alloc] initWithImage:image];
    });
    mHud.customView = imageView;
    mHud.mode = MBProgressHUDModeCustomView;
    mHud.labelText = @"Channel OK";
    sleep(2);
    
}




-(void) showHudWithStr:(NSString*) str {

    mHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:mHud];
    mHud.delegate = self;
    mHud.labelText = str;
    
    [mHud showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
}
-(void) showHudWithStr:(NSString*)str andSelector:(SEL)method{
    mHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:mHud];
    mHud.delegate = self;
    mHud.labelText = str;
    [mHud showWhileExecuting:method onTarget:self withObject:nil animated:YES];
    return;
}




- (void)myTask {
    // Do something usefull in here instead of sleeping ...
    sleep(3);
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [mHud removeFromSuperview];
    mHud = nil;
}





@end




