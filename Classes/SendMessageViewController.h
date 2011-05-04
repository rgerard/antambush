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

@interface SendMessageViewController : UIViewController<UIAlertViewDelegate> {
	UIImageView *image;
	UITextField *inputMessage;
	UIButton *attackSMSBtn;
	UIButton *attackEmailBtn;
	History *attackHistory;
	UIActivityIndicatorView *spinner;
	ASIFormDataRequest *formRequest;
	BOOL emailAttack;
}

@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UITextField *inputMessage;
@property (nonatomic, retain) IBOutlet UIButton *attackSMSBtn;
@property (nonatomic, retain) IBOutlet UIButton *attackEmailBtn;
@property (nonatomic, retain) History *attackHistory;
@property (nonatomic, retain) ASIFormDataRequest *formRequest;
@property (nonatomic) BOOL emailAttack;

-(IBAction) backgroundTap:(id) sender;
-(void)callAppDelegateToAttack;

@end
