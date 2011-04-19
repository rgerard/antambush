//
//  ContactListPicker.h
//  PandaAttack
//
//  Created by Ryan Gerard on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ContactListPicker : NSObject<ABPeoplePickerNavigationControllerDelegate,UIAlertViewDelegate> {
	NSString *personPicked;
	id delegate;
	SEL personSelector;
}

@property (nonatomic, retain) NSString *personPicked;
@property (nonatomic, retain) id delegate;
@property (nonatomic) SEL personSelector;

-(void) openContactList;
-(void) setDelegateCallback:(SEL)appSelector delegate:(id)requestDelegate;

@end
