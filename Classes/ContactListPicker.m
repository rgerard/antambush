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
@synthesize delegate;
@synthesize personSelector;

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
	
	bool startGame = false;
	
    NSString* name = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
	NSLog(@"%s",name);
	if([name isEqualToString:@"zahra"]) {
		startGame = true;
	}
	NSLog(@"%s",name);
	
	ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
	CFStringRef emailAddress;
	for (CFIndex i = 0; i < ABMultiValueGetCount(email); i++) {
		emailAddress = ABMultiValueCopyValueAtIndex(email, i);
		NSLog(@"%s",emailAddress);
	}
	
    [self.delegate dismissModalViewControllerAnimated:YES];
	
	if(startGame) {
		self.personPicked = (NSString *)emailAddress;
		
		// Call the callback, let it know that the request is done
		if([self.delegate respondsToSelector:self.personSelector]) {
			[self.delegate performSelector:self.personSelector];
		}
	} else {
		// Popup dialog now
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't find" message:@"We can't find Maryam!  Want to invite?" delegate:self cancelButtonTitle:@"Nope" otherButtonTitles:@"Hell yeah!",nil];
		[alert show];
		[alert release];
	}
	
	[name release];
	CFRelease(emailAddress);
	
    return NO;
}


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

@end
