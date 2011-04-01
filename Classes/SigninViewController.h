//
//  SigninViewController.h
//  PandaAttack
//
//  Created by Ryan Gerard on 3/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SigninViewController : UIViewController {
	UIButton *startBtn;
	UITextField *inputEmail;
}

@property (nonatomic, retain) IBOutlet UIButton *startBtn;
@property (nonatomic, retain) IBOutlet UITextField *inputEmail;

-(IBAction) backgroundTap:(id) sender;
-(void)startBtnClick:(UIView*)clickedButton;

@end
