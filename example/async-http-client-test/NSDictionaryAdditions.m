//
//  NSDictionaryAdditions.h
//  async-http-client-test
//
//  Created by Bob Wall on 6/19/12.
//

#import "NSDictionaryAdditions.h"

@implementation NSDictionary (Additions)
-(id)notNullObjectForKey:(id)aKey {
  id obj = [self objectForKey:aKey];
  if([obj isKindOfClass:[NSNull class]]) {
    return nil;
  }
  return obj;
}
@end


@implementation NSMutableDictionary (Additions)

-(void)safeSetObject:(id)obj forKey:(id)aKey {
	//if obj is nill or @"" it will do nothing
	if(!obj) {
		return;
	}
	
	if([obj isKindOfClass:[NSString class]] && [obj length]==0) {
		return;
	}
	
	[self setObject:obj forKey:aKey];
}
@end