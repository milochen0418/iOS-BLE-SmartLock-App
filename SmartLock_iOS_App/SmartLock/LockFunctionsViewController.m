//
//  LockFunctionsViewController.m
//  SmartLock
//
//  Created by Milo Chen on 2/19/15.
//  Copyright (c) 2015 Milo Chen. All rights reserved.
//

#import "LockFunctionsViewController.h"

@interface LockFunctionsViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *mGiveAKeyImgView;
@property (strong, nonatomic) IBOutlet UIImageView *mGetKeyBackImgView;
@property (strong, nonatomic) IBOutlet UIImageView *mLogStatusImgView;
@property (strong, nonatomic) IBOutlet UIScrollView *mScrollView;
@property (strong, nonatomic) IBOutlet UILabel *mReturnLbl;


@end

@implementation LockFunctionsViewController
@synthesize mGiveAKeyImgView,mGetKeyBackImgView,mLogStatusImgView;
@synthesize mScrollView;
@synthesize mReturnLbl;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [mScrollView setScrollEnabled:YES];
    [mScrollView setContentSize:CGSizeMake(320, 800)];
     
    
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

- (IBAction)clickToGiveAKey:(id)sender {
}
- (IBAction)clickToGetKeyBack:(id)sender {
}
- (IBAction)clickToOpenLogStatus:(id)sender {
}
static bool isCurrentNavBarInHidden = NO;
- (void)viewWillAppear:(BOOL)animated    // Called when the view is about to made visible. Default does nothing
{
    [self.navigationController setNavigationBarHidden:isCurrentNavBarInHidden];
    UIView *topBarView = self.navigationController.navigationBar.viewForBaselineLayout;
    topBarView.alpha = 0.0;
    mGiveAKeyImgView.alpha = 0.0;
    mGetKeyBackImgView.alpha = 0.0;
    mLogStatusImgView.alpha = 0.0;
    mReturnLbl.alpha = 0.0;
    [UIView animateWithDuration:0.7 animations:^{
        topBarView.alpha = 0.75;
    }
    completion:^(BOOL finished){
        [UIView animateWithDuration:0.3 animations:^{
            //mGiveAKeyImgView.alpha = 0.65;
            mGetKeyBackImgView.alpha = 0.75;
            mReturnLbl.alpha = 0.75;
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.3 animations:^{
                //mGetKeyBackImgView.alpha = 0.75;
                mGiveAKeyImgView.alpha = 0.75;
            } completion:^(BOOL finished){
                [UIView animateWithDuration:0.3 animations:^{
                    mLogStatusImgView.alpha = 0.75;
                } completion:^(BOOL finished){
                }];
            }];
        }];
                         
    }];
}


@end
