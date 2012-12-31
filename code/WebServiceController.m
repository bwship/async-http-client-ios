//
//  WebServiceController.m
//  async-http-client-ios
//
//  Created by Jeff DiTullio on 9/22/12.
//


#import "WebServiceController.h"
#import "WebServiceRequest.h"
#import "WebServiceResponse.h"

NSString *const kHTTPMethodGet = @"GET";
NSString *const kHTTPMethodPost = @"POST";
NSString *const kHTTPMethodPut = @"PUT";
NSString *const kHTTPMethodDelete = @"DELETE";

@implementation WebServiceController

+ (WebServiceController*)sharedInstance {
	@synchronized(self) {
		static WebServiceController *sharedInstance_ = nil;
		if (sharedInstance_ == nil) {
			sharedInstance_ = [self new];
		}
		return sharedInstance_;
	}
}

- (WebServiceResponse*)getResourceAtURL:(NSURL*)url finished:(WebServiceCallbackBlock)finished {
	WebServiceRequest *request = [WebServiceRequest new];
	request.resourceURL = url;
	return [request doRequestFinished:finished];
}

@end
