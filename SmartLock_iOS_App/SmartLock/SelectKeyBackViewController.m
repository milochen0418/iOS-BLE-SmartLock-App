//
//  SelectKeyBackViewController.m
//  SmartLock
//
//  Created by Milo Chen on 2/21/15.
//  Copyright (c) 2015 Milo Chen. All rights reserved.
//

#import "SelectKeyBackViewController.h"

@interface SelectKeyBackViewController ()

@end

@implementation SelectKeyBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickToDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void) viewDidAppear:(BOOL)animated {
//    self.view.backgroundColor = [UIColor clearColor];
    /*
    UIView *rootView = [[[[self view] window] rootViewController] view];
    //UIView *myView = [[self myViewController] view];
    UIView * myView = self.view;
    [myView setFrame:[rootView bounds]];
    [myView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [myView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [rootView addSubview:myView];
     */
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
