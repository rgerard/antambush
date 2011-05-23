//
//  FacebookUser.h
//  PandaAttack
//
//  Created by Ryan Gerard on 5/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FacebookUser : NSObject {
	NSString *fbName;
	NSString *fbID;
}

@property (nonatomic, retain) NSString *fbName;
@property (nonatomic, retain) NSString *fbID;

@end
