//
//  WebServiceRequest.h
//  async-http-client-ios
//
//  Created by Jeff DiTullio on 9/22/12.
//


#import <Foundation/Foundation.h>
#import "WebServiceController.h"

@class WebServiceResponse;

@interface WebServiceRequest : NSObject

@property (nonatomic,copy) NSURL *resourceURL;
@property (nonatomic,copy) NSString *httpMethod;
@property (nonatomic,strong) NSDictionary *params;
@property (nonatomic,strong) WebServiceResponse *response;
@property (nonatomic,copy) WebServiceCallbackBlock finished;

// Do the request, but immediately return the response (which will be empty until finished is executed)
// so it can be used for syncing if needed.
- (WebServiceResponse*)doRequestFinished:(WebServiceCallbackBlock)finished;

@end
