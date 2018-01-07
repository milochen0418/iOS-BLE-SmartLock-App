//
//  ViewController.m
//  SmartLock
//
//  Created by Milo Chen on 2/13/15.
//  Copyright (c) 2015 Milo Chen. All rights reserved.
//

#import "ViewController.h"
#import "GlobalVars.h"
#import "BLECentralRole.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIButton *mSettingBtn;
@property (strong, nonatomic) IBOutlet UIButton *mButton;
@property (strong, nonatomic) IBOutlet UIButton *mOtherGiveKeyBtn;
@property (strong, nonatomic) IBOutlet UIButton *mGiveAKeyBtn;
@property (strong, nonatomic) IBOutlet UISwitch *mTakeAKeySwitch;

@property (strong, nonatomic) IBOutlet UIButton *mOtherRequestRecvKeyBtn;

@end

@implementation ViewController
@synthesize mSettingBtn;
@synthesize mButton;
@synthesize mOtherGiveKeyBtn;
@synthesize mTakeAKeySwitch;
@synthesize mGiveAKeyBtn;
@synthesize mOtherRequestRecvKeyBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.navigationController setNavigationBarHidden:YES];
    mSettingBtn.alpha = 0.2;
    mGiveAKeyBtn.alpha = 0.2;
    [mSettingBtn setEnabled:NO];
    
    /*
    mSettingBtn.alpha = 0.3;
    mButton.layer.borderColor = [[UIColor blackColor]CGColor];
    mButton.layer.borderWidth = 0.5f;
     */
    
    
    GlobalVars *vars = [GlobalVars sharedInstance];

    vars.mBLECentralRole = [[BLECentralRole alloc] init];

    [vars.mBLECentralRole startCentralRole];
    
    
    
    
    
}

- (IBAction)onTakeAKeyChange:(id)sender {
    if([sender isOn]) {
        NSLog(@"Take a key Switch ON");
        mOtherGiveKeyBtn.hidden = NO;
        mOtherRequestRecvKeyBtn.hidden = YES;
    }
    else {
        NSLog(@"Take a key Switch OFF");
        mOtherGiveKeyBtn.hidden = YES;
        mOtherRequestRecvKeyBtn.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

static bool sIsRequestRecvKeyCancel= NO;
- (IBAction)clickToOtherRequestRecvKey:(id)sender {

    if(!sIsRequestRecvKeyCancel) {
        [self onSomeoneRequestReceiveKey];
    }
    else {
        [self onSomeoneCancelReceiveKey];
    }
    sIsRequestRecvKeyCancel = !sIsRequestRecvKeyCancel;
}

- (IBAction)clickToPressHWBtn:(id)sender {
    [self onPressHWBtn];
}

- (IBAction)clickToOtherGiveKey:(id)sender {
    [self onOtherGiveKey];
}
- (IBAction)clickToOpenGiveAKey:(id)sender {
    NSLog(@"clickToOpenGiveAKey");
   // [self cleanGuiToDefault];
}

- (IBAction)clickToOpenSetting:(id)sender {
    NSLog(@"clickToOpenSetting");
    //[mSettingBtn setBackgroundImage:[UIImage imageNamed:@"Setting_disable"] forState:UIControlStateNormal];
   // [self cleanGuiToDefault];
}

-(void) cleanGuiToDefault {
    [mSettingBtn setBackgroundImage:[UIImage imageNamed:@"black_setting_disable.jpg"] forState:UIControlStateNormal];
    mSettingBtn.alpha = 0.2;
    [mSettingBtn setEnabled:NO];
    
    sIsRequestRecvKeyCancel = YES;
    [self onSomeoneCancelReceiveKey];
    
}

- (IBAction)clickToLockFound:(id)sender {
    [self onLockFound];
}

-(void) onLockFound  {
    NSLog(@"onLockFound");
}


-(void) onSomeoneRequestReceiveKey {
    [mGiveAKeyBtn setBackgroundImage:[UIImage imageNamed:@"black_give_a_key_btn.png"] forState:UIControlStateNormal];
    mGiveAKeyBtn.alpha = 0.75;
    [mGiveAKeyBtn setEnabled:YES];
    
}

-(void) onSomeoneCancelReceiveKey {
    [mGiveAKeyBtn setBackgroundImage:[UIImage imageNamed:@"black_give_a_key_img.png"] forState:UIControlStateNormal];
    mGiveAKeyBtn.alpha = 0.2;
    [mGiveAKeyBtn setEnabled:NO];
}



-(void) onPressHWBtn {
    static bool isPressed = NO;
    isPressed = !isPressed;
    if(isPressed) {
        [mSettingBtn setBackgroundImage:[UIImage imageNamed:@"black_setting_enable.jpg"] forState:UIControlStateNormal];
        mSettingBtn.alpha = 0.75;
        [mSettingBtn setEnabled:YES];
    }
    else {
        [mSettingBtn setBackgroundImage:[UIImage imageNamed:@"black_setting_disable.jpg"] forState:UIControlStateNormal];
        mSettingBtn.alpha = 0.2;
        [mSettingBtn setEnabled:NO];
    }
}

-(void) onOtherGiveKey  {
    //self.navigationController pushViewController:<#(UIViewController *)#> animated:<#(BOOL)#>
    mOtherGiveKeyBtn.hidden = YES ;
    [mTakeAKeySwitch setOn:NO animated:NO];

}



static bool isCurrentNavBarInHidden = YES;
- (void)viewWillAppear:(BOOL)animated    // Called when the view is about to made visible. Default does nothing
{
    
    [self.navigationController setNavigationBarHidden:isCurrentNavBarInHidden];
}

-(void)viewDidDisappear:(BOOL)animated {
    [self cleanGuiToDefault];
}

@end
