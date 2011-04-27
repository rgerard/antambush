//
//  UIImageAlertView.h
//  PandaAttack
//
//  Created by Ryan Gerard on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImageAlertView : UIAlertView {
	UIImage *image;
	UIImageView *imageView;
	NSString *attackName;
}

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) NSString *attackName;

-(void)setImage:(UIImage*)initimage attackNameStr:(NSString *)attackNameStr;
+(UIImage*)imageWithImage:(UIImage*)oldimage scaledToSize:(CGSize)newSize;

@end
