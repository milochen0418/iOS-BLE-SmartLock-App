//
//  GetKeyBackViewController.m
//  SmartLock
//
//  Created by Milo Chen on 2/21/15.
//  Copyright (c) 2015 Milo Chen. All rights reserved.
//

#import "GetKeyBackViewController.h"
#import "SelectKeyBackViewController.h"
@interface GetKeyBackViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *mPhotoImgView;
@property (strong, nonatomic) IBOutlet UIImageView *mSelectPhotoImgView;
@property (strong, nonatomic) IBOutlet UILabel *mShowTextLbl;

@property (nonatomic,strong) UIViewController * mSelectKeyBackVC;
@end

@implementation GetKeyBackViewController
@synthesize mPhotoImgView,mSelectPhotoImgView,mShowTextLbl;
@synthesize mSelectKeyBackVC;

- (IBAction)clickToSelectKeyBack:(id)sender {
    NSLog(@"clickToSelectKeyBack");
    
    UIViewController * presentedVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectKeyBackViewController"];
    self.definesPresentationContext = YES;
    //presentedVC.view.backgroundColor =[UIColor clearColor];
    presentedVC.view.backgroundColor =[UIColor blackColor];
    presentedVC.view.alpha = 0.75;
    presentedVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:presentedVC animated:YES completion:^{
        
    }];
}


- (IBAction)clickToGetKeyBack:(id)sender {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIStoryboard * storyboard = self.storyboard;
    
    //mSelectKeyBackVC = [[SelectKeyBackViewController alloc] init];
    mSelectKeyBackVC = [storyboard instantiateViewControllerWithIdentifier:@"SelectKeyBackViewController"];
    
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

@end
