//
//  SmartLockUtilityViewController.m
//  SmartLock
//
//  Created by Milo Chen on 3/3/15.
//  Copyright (c) 2015 Milo Chen. All rights reserved.
//

#import "SmartLockUtilityViewController.h"
#import "SmartLockUtility.h"
@interface SmartLockUtilityViewController ()

@end

@implementation SmartLockUtilityViewController



- (IBAction)clickToToggleOwnerLockUnlockTEST:(id)sender {
    [[SmartLockUtility sharedInstance] requestGetLockStatusWithComplete:^(uint8_t ch, BOOL isConnectFailed) {
        NSLog(@"requestGetLockStatusWithComplete recv %c", ch);
        if(ch == 'L') {
            NSLog(@"requestOwnerDoUnlock Start");
            [[SmartLockUtility sharedInstance] requestOwnerDoUnlockWithComplete:^(BOOL isConnectFailed) {
                NSLog(@"requestOwnerDoUnlock Complete");
            }];
        }else if(ch=='U') {
            NSLog(@"requestOwnerDoLock Start");
            [[SmartLockUtility sharedInstance] requestOwnerDoLockWithComplete:^(BOOL isConnectFailed) {
                NSLog(@"requestOwnerDoLock Complete");
            }];
        } else {
            NSLog(@"recv ch from BLE is not according to Lock(L) or  Unlock(U)");
        }
    }];
}


- (IBAction)clickToNestOwnerLockUnlockTEST:(id)sender {
    [[SmartLockUtility sharedInstance] requestOwnerDoLockWithComplete:^(BOOL isConnectFailed) {
        if(isConnectFailed == YES) {
            NSLog(@"connect is  failed");
            return;
        }
        else {
            NSLog(@"requestOwnerDoLockWithComplete is work 1");
            
            [[SmartLockUtility sharedInstance] requestOwnerDoUnlockWithComplete:^(BOOL isConnectFailed) {
                if(isConnectFailed == YES) {
                    NSLog(@"connect is failed");
                    return;
                }
                else {
                    NSLog(@"requestOwnerDoUnlockWithComplete is work 2");
                    
                    [[SmartLockUtility sharedInstance] requestOwnerDoLockWithComplete:^(BOOL isConnectFailed) {
                        if(isConnectFailed == YES) {
                            NSLog(@"connect is failed");
                            return;
                        }
                        else {
                            NSLog(@"requestOwnerDoLockWithComplete is work 3");
                            [[SmartLockUtility sharedInstance] requestOwnerDoUnlockWithComplete:^(BOOL isConnectFailed) {
                                if(isConnectFailed == YES) {
                                    NSLog(@"connect is failed");
                                    return;
                                }
                                else {
                                    NSLog(@"requestOwnerDoUnlockWithComplete is work 4");
                                    return;
                                }
                            }];
                            return;
                        }
                    }];
                    return;
                }
            }];
            return;
        }
    }];
}

- (IBAction)clickToOnwerDoLock:(id)sender {
    [[SmartLockUtility sharedInstance] requestOwnerDoLockWithComplete:^(BOOL isConnectFailed) {
        if(isConnectFailed == YES) {
            NSLog(@"connect is  failed");
            return;
        }
        else {
            NSLog(@"requestOwnerDoLockWithComplete is work 1");
        }
    }];
}
- (IBAction)clickToOwnerDoUnlock:(id)sender {
    [[SmartLockUtility sharedInstance] requestOwnerDoUnlockWithComplete:^(BOOL isConnectFailed) {
        if(isConnectFailed == YES) {
            NSLog(@"connect is failed");
            return;
        }
        else {
            NSLog(@"requestOwnerDoUnlockWithComplete is work");
            return;
        }
    }];    
}
- (IBAction)clickToGuestDoLock:(id)sender {
    [[SmartLockUtility sharedInstance] requestGuestDoLockWithComplete:^(BOOL isConnectFailed) {
        if(isConnectFailed == YES) {
            NSLog(@"connect is  failed");
            return;
        }
        else {
            NSLog(@"requestGuestDoLockWithComplete is work");
        }
    }];
}
- (IBAction)clickToGuestDoUnlock:(id)sender {
    [[SmartLockUtility sharedInstance] requestGuestDoUnlockWithComplete:^(BOOL isConnectFailed) {
        if(isConnectFailed == YES) {
            NSLog(@"connect is  failed");
            return;
        }
        else {
            NSLog(@"requestGuestDoUnlockWithComplete is work");
        }
    }];
}

- (IBAction)clickToGetLockStatus:(id)sender {
    [[SmartLockUtility sharedInstance] requestGetLockStatusWithComplete:^(uint8_t ch, BOOL isConnectFailed) {
        if(isConnectFailed == YES) {
            NSLog(@"connect is failed");
            return;
        }
        else {
            NSLog(@"requestGetLockStatusWithComplete is work with recvByte=%c", ch);
            
            return;
        }
    }];
}


- (IBAction)clickToGiveKey:(id)sender {
    [[SmartLockUtility sharedInstance] requestGiveKeyWithComplete:^(BOOL isConnectFailed) {
        if(isConnectFailed == YES) {
            NSLog(@"connect is  failed");
            return;
        }
        else {
            NSLog(@"requestGiveKeyWithComplete is work");
        }
    }];
}
- (IBAction)clickToReturnKey:(id)sender {
    [[SmartLockUtility sharedInstance] requestReturnKeyWithComplete:^(BOOL isConnectFailed) {
        if(isConnectFailed == YES) {
            NSLog(@"connect is  failed");
            return;
        }
        else {
            NSLog(@"requestReturnKeyWithComplete is work");
        }
    }];
}

- (IBAction)clickToGetKeyStatus:(id)sender {
    [[SmartLockUtility sharedInstance] requestGetKeyStatusWithComplete:^(uint8_t ch, BOOL isConnectFailed) {
        if(isConnectFailed == YES) {
            NSLog(@"connect is failed");
            return;
        }
        else {
            NSLog(@"requestGetKeyStatusWithComplete is work with recvByte=%c", ch);
            return;
        }
    }];
}

- (IBAction)clickToInReceiving:(id)sender {
    [[SmartLockUtility sharedInstance] requestInReceivingWithComplete:^(BOOL isConnectFailed) {
        if(isConnectFailed == YES) {
            NSLog(@"connect is  failed");
            return;
        }
        else {
            NSLog(@"requestInReceivingWithComplete is work");
        }
    }];
}

- (IBAction)clickToNotInReceiving:(id)sender {
    [[SmartLockUtility sharedInstance] requestNotInReceivingWithComplete:^(BOOL isConnectFailed) {
        if(isConnectFailed == YES) {
            NSLog(@"connect is  failed");
            return;
        }
        else {
            NSLog(@"requestNotInReceivingWithComplete is work");
        }
    }];
}

- (IBAction)clickToIsInReceiving:(id)sender {
    [[SmartLockUtility sharedInstance] requestIsInReceivingWithComplete:^(uint8_t ch, BOOL isConnectFailed) {
        if(isConnectFailed == YES) {
            NSLog(@"connect is failed");
            return;
        }
        else {
            NSLog(@"requestIsInReceivingWithComplete is work with recvByte=%c", ch);
            return;
        }
    }];
}






- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
