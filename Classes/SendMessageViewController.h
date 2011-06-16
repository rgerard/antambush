//
//  SendMessageViewController.h
//  PandaAttack
//
//  Created by Ryan Gerard on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "History.h"
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"

@interface SendMessageViewController : UIViewController<UIAlertViewDelegate> {
	UIImageView *image;
	UITextField *inputMessage;
	UIButton *attackBtn;
	History *attackHistory;
	MBProgressHUD *spinner;
	ASIFormDataRequest *formRequest;
}

@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UITextField *inputMessage;
@property (nonatomic, retain) IBOutlet UIButton *attackBtn;
@property (nonatomic, retain) History *attackHistory;
@property (nonatomic, retain) ASIFormDataRequest *formRequest;

-(IBAction) backgroundTap:(id) sender;
-(void)callAppDelegateToAttack;
-(void) setSpinningMode:(BOOL)isWaiting detailTxt:(NSString *)detailTxt;

@end
