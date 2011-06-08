//
//  SigninViewController.h
//  PandaAttack
//
//  Created by Ryan Gerard on 3/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookWrapper.h"

@interface SigninViewController : UIViewController {
	UIButton *startBtn;
	UIButton *facebookBtn;
	UITextField *inputEmail;
	FacebookWrapper *fbWrapper;
}

@property (nonatomic, retain) IBOutlet UIButton *startBtn;
@property (nonatomic, retain) IBOutlet UIButton *facebookBtn;
@property (nonatomic, retain) IBOutlet UITextField *inputEmail;
@property (nonatomic, retain) FacebookWrapper *fbWrapper;

-(id)initWithWrapper:(FacebookWrapper *)wrapper;
-(IBAction) backgroundTap:(id) sender;
-(void) startBtnClick:(UIView*)clickedButton;
-(void) setFbWrapper:(FacebookWrapper*)wrapper;
-(void) facebookLoginCallback;

@end
