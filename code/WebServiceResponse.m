//
//  WebServiceResponse.m
//  async-http-client-ios
//
//  Created by Jeff DiTullio on 9/22/12.
//

#import "WebServiceResponse.h"

@interface WebServiceResponse ()
@property (nonatomic,strong) NSDictionary *dictionary;
@end


@implementation WebServiceResponse
@synthesize dictionary = dictionary_;
@synthesize httpHeaders = httpHeaders_;
@synthesize httpStatus = httpStatus_;
@synthesize systemError = systemError_;
@synthesize data = data_;

- (BOOL)success {
	return (self.httpStatus>=200 && self.httpStatus<=299);
}
- (BOOL)successDictionary {
	return (self.httpStatus>=200 && self.httpStatus<=299 && self.dictionary!=nil);
}

- (BOOL)didTimeout {
	if (([self.systemError domain] == NSURLErrorDomain) && ([self.systemError code] == NSURLErrorTimedOut)) {
		return YES;
	}
	return NO;
}

- (NSDictionary*)dictionary {
	if (dictionary_ == nil) {
		self.dictionary = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:nil];
	}
	return dictionary_;
}
@end