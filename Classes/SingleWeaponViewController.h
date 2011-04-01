//
//  SingleWeaponViewController.h
//  PandaAttack
//
//  Created by Ryan Gerard on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SingleWeaponViewController : UIViewController {
    int pageNumber;
    
	UIButton *imageBtn;
    UILabel *numberTitle;
    UIImageView *numberImage;
	NSString *imageName;
}

@property (nonatomic, retain) IBOutlet UIButton *imageBtn;
@property (nonatomic, retain) IBOutlet UILabel *numberTitle;
@property (nonatomic, retain) IBOutlet UIImageView *numberImage;
@property (nonatomic, retain) NSString *imageName;

- (id)initWithPageNumber:(int)page;

@end
