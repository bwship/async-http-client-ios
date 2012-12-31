//
//  NSDictionaryAdditions.h
//  async-http-client-test
//
//  Created by Bob Wall on 6/19/12.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Additions)
//Returns nil if object is NSNull - to get around messaging NSNull
//Thats right, a legitimate reason to use the term Not Null :)
-(id)notNullObjectForKey:(id)aKey;
@end


@interface NSMutableDictionary (Additions)
//if obj is nill or @"" it will do nothing
-(void)safeSetObject:(id)obj forKey:(id)aKey;
@end