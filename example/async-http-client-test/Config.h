//
//  Config.h
//  async-http-client-test
//
//  Created by Bob Wall on 12/31/12.
//  Copyright (c) 2012 Wall Mobile Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject

//Mongo Database API Key and Collections
#define MONGO_DATABASE          @"https://api.mongolab.com/api/1/databases/YOUR_MONGO_COLLECTION/collections/"
#define MONGO_API_KEY           @"YOUR_MONGO_API_KEY"
#define MONGO_API_ITEMS         @"items"

@end
