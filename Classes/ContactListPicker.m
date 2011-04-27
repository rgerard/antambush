//
//  ContactListPicker.m
//  PandaAttack
//
//  Created by Ryan Gerard on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContactListPicker.h"


@implementation ContactListPicker

@synthesize personPicked;
@synthesize personPickedName;
@synthesize delegate;
@synthesize personSelector;

-(id) init {
	self = [super init];
    if (self) {
        // Custom initialization.
		self.personPicked = [[NSMutableArray alloc] initWithObjects:nil];
    }
    return self;	
}

-(void) setDelegateCallback:(SEL)appSelector delegate:(id)requestDelegate {
	self.delegate = requestDelegate;
	self.personSelector = appSelector;
}

-(void) openContactList {
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
	
    [self.delegate presentModalViewController:picker animated:YES];
    [picker release];	
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self.delegate dismissModalViewControllerAnimated:YES];
	
	// Popup dialog now asking to input email address
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Want to add?" message:@"Couldn't find the person you're looking for?  Do you want to input their email address now?" delegate:self cancelButtonTitle:@"Nope" otherButtonTitles:@"Hell yeah!",nil];
	[alert show];
	[alert release];
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	
	//bool startGame = false;
	
    NSString* name = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
	self.personPickedName = name;
	NSLog(@"%s",name);
	//if([name isEqualToString:@"zahra"]) {
	//	startGame = true;
	//}
	//NSLog(@"%s",name);
	
	[self.personPicked removeAllObjects];
	ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
	
	if (ABMultiValueGetCount(email) > 0) {
        // collect all emails in array
        for (CFIndex i = 0; i < ABMultiValueGetCount(email); i++) {
            CFStringRef emailRef = ABMultiValueCopyValueAtIndex(email, i);
            [self.personPicked addObject:(NSString *)emailRef];
            CFRelease(emailRef);
        }
    }
    CFRelease(email);
	
	// Dismiss the contact list picker dialog
    [self.delegate dismissModalViewControllerAnimated:YES];
	
	if(self.personPicked != nil && [self.personPicked count] > 0) {
		
		// Call the callback, let it know that the request is done
		if([self.delegate respondsToSelector:self.personSelector]) {
			[self.delegate performSelector:self.personSelector];
		}
	} else {
		// Popup dialog now
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No email address" message:[NSString stringWithFormat:@"You don't have the email address for %@!  Do you want to invite?",name] delegate:self cancelButtonTitle:@"Nope" otherButtonTitles:@"Hell yeah!",nil];
		[alert show];
		[alert release];
	}
	
	[name release];

    return NO;
}


// Responds to people saying they want to invite someone
/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {  
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];  
	
    if([title isEqualToString:@"Hell yeah!"]) {  
        NSLog(@"Please invite");
		
		if([MFMailComposeViewController canSendMail]) {
			
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			picker.mailComposeDelegate = self;
			[picker setSubject:@"Hello iPhone!"];
			
			// Set up recipients
			NSArray *toRecipients = [NSArray arrayWithObject:@"ryan.gerard@gmail.com"];
			NSString *emailBody = @"Nice  to See you!";
			[picker setToRecipients:toRecipients];
			[picker setMessageBody:emailBody isHTML:NO];
			
			[self presentModalViewController:picker animated:YES];
			[picker release];
		} else {
			NSLog(@"Device can't send mail!");
		}
    } else if([title isEqualToString:@"Attack back"]) {
		NSLog(@"Uesr wants to attack back");
		[self changeToWeaponView];
	}
} 
*/

// respond to the ask button click
-(void)personBtnClick:(UIView*)clickedButton {
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
	CFErrorRef anError;
	
	ABRecordRef aRecord = ABPersonCreate();
	ABRecordSetValue(aRecord, kABPersonFirstNameProperty, CFSTR("zahra"), &anError);
	ABRecordSetValue(aRecord, kABPersonLastNameProperty, CFSTR("ghofraniha"), &anError);
	
	ABMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	ABMultiValueAddValueAndLabel(email, @"zahra.ghofraniha@gmail.com", kABHomeLabel, NULL);
	ABMultiValueAddValueAndLabel(email, @"zahrag@google.com", kABWorkLabel, NULL);
	
	ABRecordSetValue(aRecord, kABPersonEmailProperty, email, &anError);
	
	ABAddressBookAddRecord(addressBook, aRecord, &anError);
	ABAddressBookSave(addressBook, &anError);
	
	CFRelease(aRecord);
	CFRelease(addressBook);
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}

- (void)dealloc {
	[personPicked release];
	[personPickedName release];
	[super dealloc];
}

@end
