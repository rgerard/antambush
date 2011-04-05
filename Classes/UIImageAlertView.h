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
}

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImageView *imageView;

+(UIImage*)imageWithImage:(UIImage*)oldimage scaledToSize:(CGSize)newSize;

@end
