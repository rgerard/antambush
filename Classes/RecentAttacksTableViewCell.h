//
//  RecentAttacksTableViewCell.h
//  PandaAttack
//
//  Created by Ryan Gerard on 4/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "History.h"

@interface RecentAttacksTableViewCell : UITableViewCell {
	UILabel *personName;
	UILabel *attackName;
	UILabel *message;
	UILabel *connectingString;
}

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;
-(void)setData:(History *)historyObject;

@property (nonatomic, retain) UILabel *personName;
@property (nonatomic, retain) UILabel *message;
@property (nonatomic, retain) UILabel *attackName;
@property (nonatomic, retain) UILabel *connectingString;

@end
