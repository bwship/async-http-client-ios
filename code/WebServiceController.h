//
//  WebServiceController.h
//  async-http-client-ios
//
//  Created by Jeff DiTullio on 9/22/12.
//


extern NSString *const kHTTPMethodGet;
extern NSString *const kHTTPMethodPost;
extern NSString *const kHTTPMethodPut;
extern NSString *const kHTTPMethodDelete;

@class WebServiceResponse;
typedef void(^WebServiceCallbackBlock)(WebServiceResponse*);

@interface WebServiceController : NSObject

+ (WebServiceController*)sharedInstance;

@end
