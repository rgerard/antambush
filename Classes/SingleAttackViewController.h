//
//  SingleAttackViewController.h
//  PandaAttack
//
//  Created by Ryan Gerard on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "History.h"

@interface SingleAttackViewController : UIViewController {
	UILabel *attackerLabel;
	UIImageView *attackImage;
	UILabel *messageLabel;
	UIButton *attackBackBtn;
	History *attackData;
}

@property (nonatomic, retain) IBOutlet UILabel *attackerLabel;
@property (nonatomic, retain) IBOutlet UIImageView *attackImage;
@property (nonatomic, retain) IBOutlet UILabel *messageLabel;
@property (nonatomic, retain) IBOutlet UIButton *attackBackBtn;
@property (nonatomic, retain) History *attackData;

-(void) addAttackData:(History *)item;

@end
