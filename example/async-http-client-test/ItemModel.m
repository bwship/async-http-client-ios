//
//  ItemModel.m
//  async-http-client-test
//
//  Created by Bob Wall on 12/31/12.
//  Copyright (c) 2012 Wall Mobile Solutions. All rights reserved.
//

#import "ItemModel.h"
#import "NSDictionaryAdditions.h"
#import "WebServiceResponse.h"
#import "WebServiceRequest.h"
#import "Config.h"

@implementation ItemModel

@synthesize itemId = _itemId;
@synthesize name = _name;
@synthesize description = _description;
@synthesize itemDate = itemDate_;

/* parse an item dictionary into an item object */
+ (ItemModel*)parseDictionary:(NSDictionary*)dictionary {
	ItemModel* item = [[ItemModel alloc] init];
	
	item.itemId = [[dictionary notNullObjectForKey:@"_id"] notNullObjectForKey:@"$oid"];
	item.name = [dictionary notNullObjectForKey:@"name"];
	item.description = [dictionary notNullObjectForKey:@"description"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ssz"];
	item.itemDate = [dateFormat dateFromString:[dictionary notNullObjectForKey:@"date"]];
        
	return item;
}

/* restful api call to get items for the specified category */
+ (WebServiceResponse*)getItemsLimit:(int)limit
                            finished:(WebServiceCallbackBlock)finished {
	WebServiceRequest *request = [WebServiceRequest new];
	request.resourceURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                                MONGO_DATABASE,
												MONGO_API_ITEMS]];
    
    request.params = [NSDictionary dictionaryWithObjectsAndKeys:
                          MONGO_API_KEY, @"apiKey",
                          [NSString stringWithFormat:@"%d", limit], @"l",
                          nil];
    
	request.httpMethod = kHTTPMethodGet;
	
	return [request doRequestFinished:finished];
}

/* add an item to the database */
+ (WebServiceResponse*)item:(ItemModel*)item
                   finished:(WebServiceCallbackBlock)finished {
    WebServiceRequest *request = [WebServiceRequest new];
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS Z"];
    
    request.params = [NSDictionary dictionaryWithObjectsAndKeys:
                      item.name, @"name",
                      item.description, @"description",
                      [dateFormat stringFromDate:currentDate], @"itemDate",
                      nil];
    
    /* the item has not been voted on by this user, and it is either an up or down vote, so post it to mongo */
    request.resourceURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?apiKey=%@",
                                                MONGO_DATABASE,
                                                MONGO_API_ITEMS,
                                                MONGO_API_KEY]];
    request.httpMethod = kHTTPMethodPost;
    
    return [request doRequestFinished:finished];
}

/* load the returned items from the api call */
+ (NSArray*)loadItemsFromDictionary:(NSDictionary*)dictionary {
    @synchronized(self) {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (NSDictionary *itemDictionary in dictionary) {
            ItemModel *item = [ItemModel parseDictionary:itemDictionary];
            [items addObject:item];
        }
        
        //sort items
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemDate" ascending:YES];
        [items sortedArrayUsingDescriptors: [NSArray arrayWithObject:sortDescriptor]];
        
        return [items sortedArrayUsingDescriptors: [NSArray arrayWithObject:sortDescriptor]];
    }
}

@end
