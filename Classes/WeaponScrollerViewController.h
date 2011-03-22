//
//  WeaponScrollerViewController.h
//  PandaAttack
//
//  Created by Ryan Gerard on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "History.h"

@interface WeaponScrollerViewController : UIViewController<UIScrollViewDelegate> {
	UIScrollView *scrollView;
    UIPageControl *pageControl;
    NSMutableArray *viewControllers;
	NSArray *contentList;
	History *attackHistory;
    
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic, retain) NSArray *contentList;
@property (nonatomic, retain) History *attackHistory;

- (IBAction)changePage:(id)sender;
- (void)loadScrollViewWithPage:(int)page;
-(void)imageBtnClick:(UIView*)clickedButton;

@end
