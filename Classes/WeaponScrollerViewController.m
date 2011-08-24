//
//  WeaponScrollerViewController.m
//  PandaAttack
//
//  Created by Ryan Gerard on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WeaponScrollerViewController.h"
#import "SingleWeaponViewController.h"
#import "SendMessageViewController.h"
#import "MixpanelAPI.h"

static NSUInteger kNumberOfPages = 10;
static NSString *NameKey = @"nameKey";
static NSString *ImageKey = @"imageKey";

@implementation WeaponScrollerViewController

@synthesize scrollView, pageControl, viewControllers, contentList, attackHistory;

- (void)viewDidLoad {
    // load our data from a plist file inside our app bundle
    NSString *path = [[NSBundle mainBundle] pathForResource:@"iphone_contents" ofType:@"plist"];
    self.contentList = [NSArray arrayWithContentsOfFile:path];
	
	// view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfPages; i++) {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    [controllers release];
	
	// a page is the width of the scroll view
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height - 44);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    pageControl.numberOfPages = kNumberOfPages;
    pageControl.currentPage = 0;
	
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    //
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
	
	[self.view addSubview:scrollView];
}


- (void)loadScrollViewWithPage:(int)page {
    if (page < 0)
        return;
    if (page >= kNumberOfPages)
        return;
    
    // replace the placeholder if necessary
    SingleWeaponViewController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[SingleWeaponViewController alloc] initWithPageNumber:page];
        [viewControllers replaceObjectAtIndex:page withObject:controller];
        [controller release];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil) {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
        
        NSDictionary *numberItem = [self.contentList objectAtIndex:page];
        controller.numberImage.image = [UIImage imageNamed:[numberItem valueForKey:ImageKey]];
        controller.numberTitle.text = [numberItem valueForKey:NameKey];
		controller.imageName = [numberItem valueForKey:ImageKey];
		
		[controller.imageBtn addTarget:self action:@selector(imageBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}


// respond to the ask button click
-(void)imageBtnClick:(UIView*)clickedButton {
    SingleWeaponViewController *controller = [viewControllers objectAtIndex:pageControl.currentPage];
	NSLog(@"Clicked %@", controller.imageName);
	
    MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
	[mixpanel trackFunnel:@"Attack Friend" step:4 goal:@"Weapon Selected" properties:[NSDictionary dictionaryWithObject:controller.imageName forKey:@"weapon"]];
    [mixpanel track:@"WeaponSelected" properties:[NSDictionary dictionaryWithObject:controller.imageName forKey:@"weapon"]];
    
	// Fill the history item
	attackHistory.attack = controller.imageName;
	
	SendMessageViewController *messageViewController = [[SendMessageViewController alloc] init];
	messageViewController.title = @"Send Message";
	messageViewController.attackHistory = attackHistory;
	[self.navigationController pushViewController:messageViewController animated:YES];
	[messageViewController release];
}


- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}


// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}


// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}


- (IBAction)changePage:(id)sender {
    int page = pageControl.currentPage;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
    // Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [viewControllers release];
    [scrollView release];
    [pageControl release];	
	[contentList release];
    [super dealloc];
}


@end
