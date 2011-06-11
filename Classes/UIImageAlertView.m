//
//  UIImageAlertView.m
//  PandaAttack
//
//  Created by Ryan Gerard on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImageAlertView.h"


@implementation UIImageAlertView

@synthesize image, imageView, attackName;

-(void)setImage:(UIImage*)initimage attackNameStr:(NSString *)attackNameStr {
	CGSize size = CGSizeMake(100, 100);
	self.image = [UIImageAlertView imageWithImage:initimage scaledToSize:size];
	self.imageView = [[UIImageView alloc] initWithImage:image];
	self.attackName = attackNameStr;
	
	[self addSubview:imageView];	
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

// Tell the UIAlertView frame to have a larger height, to accomodate the picture
- (void)setFrame:(CGRect)rect {
	[super setFrame:CGRectMake(0, 0, rect.size.width, 280)];
	self.center = CGPointMake(320/2, 480/2);
}


// Layout the 100px by 100px picture correctly
- (void)layoutSubviews {
	CGFloat buttonTop = 0;
	for (UIView *view in self.subviews) {
		if ([[[view class] description] isEqualToString:@"UIThreePartButton"]) {
			view.frame = CGRectMake(view.frame.origin.x, self.bounds.size.height - view.frame.size.height - 15, view.frame.size.width, view.frame.size.height);
			buttonTop = view.frame.origin.y;
		}
	}
	
	buttonTop -= 7; 
	buttonTop -= 100;
	imageView.frame = CGRectMake( ((self.frame.size.width - 125)/2), buttonTop, 100, 100);
}


+(UIImage*)imageWithImage:(UIImage*)oldimage scaledToSize:(CGSize)newSize {
	UIGraphicsBeginImageContext( newSize );
	[oldimage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	[imageView release];
    [super dealloc];
}


@end
