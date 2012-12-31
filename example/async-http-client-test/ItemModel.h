//
//  ItemModel.h
//  async-http-client-test
//
//  Created by Bob Wall on 12/31/12.
//  Copyright (c) 2012 Wall Mobile Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebServiceResponse.h"
#import "WebServiceController.h"

@interface ItemModel : NSObject

@property (strong) NSString* itemId;
@property (strong) NSString *name;
@property (strong) NSString *description;
@property (strong) NSDate *itemDate;

/* parse an item dictionary into an item object */
+ (ItemModel*)parseDictionary:(NSDictionary*)dictionary;

/* restful api call to get items */
+ (WebServiceResponse*)getItemsLimit:(int)limit
                            finished:(WebServiceCallbackBlock)finished;

/* restful api call add an item */
+ (WebServiceResponse*)item:(ItemModel*)item
                   finished:(WebServiceCallbackBlock)finished;

/* load the returned items from the api call */
+ (NSArray*)loadItemsFromDictionary:(NSDictionary*)dictionary;

@end
