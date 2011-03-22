//
//  SendMessageViewController.h
//  PandaAttack
//
//  Created by Ryan Gerard on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "History.h"

@interface SendMessageViewController : UIViewController {
	UIImageView *image;
	UITextField *inputMessage;
	UIButton *attackBtn;
	History *attackHistory;
}

@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UITextField *inputMessage;
@property (nonatomic, retain) IBOutlet UIButton *attackBtn;
@property (nonatomic, retain) History *attackHistory;

-(IBAction) backgroundTap:(id) sender;

@end
