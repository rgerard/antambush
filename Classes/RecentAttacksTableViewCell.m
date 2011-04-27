//
//  RecentAttacksTableViewCell.m
//  PandaAttack
//
//  Created by Ryan Gerard on 4/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RecentAttacksTableViewCell.h"
#import "PandaAttackAppDelegate.h"

static NSString *ImageKey = @"imageKey";
static NSString *NameKey = @"nameKey";

@implementation RecentAttacksTableViewCell

@synthesize personName, attackName, connectingString, message;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		// We need a view to place our labels on.
		UIView *myContentView = self.contentView;
		
		/*
		 init the personName label.
		 set the text alignment to align on the left
		 add the label to the subview
		 release the memory
		 */
		self.personName = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor whiteColor] fontSize:14.0 bold:YES];
		self.personName.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview:self.personName];
		[self.personName release];

        self.attackName = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:10.0 bold:NO];
		self.attackName.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview:self.attackName];
		[self.attackName release];		
		
		/*
		 init the message label. (you will see a difference in the font color and size here!
		 set the text alignment to align on the left
		 add the label to the subview
		 release the memory
		 */
        self.message = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:10.0 bold:NO];
		self.message.textAlignment = UITextAlignmentLeft; // default
		[myContentView addSubview:self.message];
		[self.message release];
    }
    return self;
}

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold {
	/*
	 Create and configure a label.
	 */
	
    UIFont *font;
    if (bold) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    } else {
        font = [UIFont systemFontOfSize:fontSize];
    }
	
    /*
	 Views are drawn most efficiently when they are opaque and do not have a clear background, so set these defaults.  To show selection properly, however, the views need to be transparent (so that the selection color shows through).  This is handled in setSelected:animated:.
	 */
	UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	newLabel.backgroundColor = [UIColor whiteColor];
	newLabel.opaque = YES;
	newLabel.textColor = primaryColor;
	newLabel.highlightedTextColor = selectedColor;
	newLabel.font = font;
	
	return newLabel;
}


/*
	Set the data that this cell will show
 */
-(void)setData:(History *)historyObject {
	PandaAttackAppDelegate *appDelegate = (PandaAttackAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSDictionary *numberItem = [appDelegate findAttackInPList:historyObject.attack];
	
	if(numberItem != nil) {
		self.attackName.text = [numberItem valueForKey:NameKey];
	}
	
	self.personName.text = historyObject.contactName;
	
	if([historyObject.message length] != 0) {
		self.message.text = [NSString stringWithFormat:@"\"%@\"", historyObject.message];
	} else {
		self.message.text = historyObject.message;
	}
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


/*
 this function will layout the subviews for the cell
 if the cell is not in editing mode we want to position them
 */
- (void)layoutSubviews {
	
    [super layoutSubviews];
	
	// getting the cell size
    CGRect contentRect = self.contentView.bounds;
	
	// In this example we will never be editing, but this illustrates the appropriate pattern
    if (!self.editing) {
		
		// get the X pixel spot
        CGFloat boundsX = contentRect.origin.x;
		CGRect frame;
		
        /*
		 Place the name and attack name labels.
		 place the label whatever the current X is plus 10 pixels from the left
		 place the label 4 pixels from the top
		 make the label 200 pixels wide
		 make the label 20 pixels high
		 */
		frame = CGRectMake(boundsX + 10, 4, 150, 20);
		self.personName.frame = frame;

		// place the attack name label
		frame = CGRectMake(boundsX + 160, 4, 100, 20);
		self.attackName.frame = frame;		
		
		// place the message label
		frame = CGRectMake(boundsX + 10, 28, 200, 14);
		self.message.frame = frame;
	}
}


- (void)dealloc {
	[personName release];
	[attackName release];
	[connectingString release];
    [super dealloc];
}


@end
