//
//  WebServiceRequest.m
//  async-http-client-ios
//
//  Created by Jeff DiTullio on 9/22/12.
//

#import <CommonCrypto/CommonDigest.h>

#import "WebServiceRequest.h"
#import "WebServiceController.h"
#import "WebServiceResponse.h"

#define NETWORK_JPEG_COMPRESSION		.6
#define NETWORK_SHORT_TIMEOUT			15	//Used for GET
#define NETWORK_LONG_TIMEOUT			60	//Used for POST

@interface WebServiceRequest () 
- (void)incrementNetworkRequestsInProgress;
- (void)decrementNetworkRequestsInProgress;
+ (NSString*)stringByDecodingURLFormat:(NSString*)encodedString;
+ (NSURL*)urlByAddingQueryStringParams:(NSDictionary*)params toURL:(NSURL*)url;
+ (NSString*)md5:(NSString*)string;
@end


@implementation WebServiceRequest

@synthesize resourceURL = resourceURL_;
@synthesize httpMethod = httpMethod_;
@synthesize params = params_;
@synthesize response = response_;
@synthesize finished = finished_;

-(id)init {
	if ((self = [super init])) {
		self.httpMethod = kHTTPMethodGet;
		self.response = [WebServiceResponse new];
	}
	return self;
}

// Do the request, but immediately return the response (which will be empty until finished is executed)
// so it can be used for syncing if needed.
- (WebServiceResponse*)doRequestFinished:(WebServiceCallbackBlock)finished {
	self.finished = finished;
	
	// Add the common params

	// Start the request in new thread
	[NSThread detachNewThreadSelector:@selector(doRequest) toTarget:self withObject:nil];
	
	// Immediately return empty response so the caller can compare it for syncronization
	return self.response;
}


- (void)doRequest {

	@autoreleasepool {
		
		// Create request
		NSMutableURLRequest *theRequest = [NSMutableURLRequest new];
		// Set timeout
		if (self.httpMethod==kHTTPMethodGet || self.httpMethod==kHTTPMethodDelete) {
			[theRequest setTimeoutInterval:NETWORK_SHORT_TIMEOUT];
		}
		else {
			[theRequest setTimeoutInterval:NETWORK_LONG_TIMEOUT];
		}
		// Set method
		[theRequest setHTTPMethod:self.httpMethod];
		
		if ([self.httpMethod isEqualToString:@"GET"]) {
			[theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
			
			// GET - setup query string
			[theRequest setURL:[WebServiceRequest urlByAddingQueryStringParams:self.params toURL:self.resourceURL]];
			
			// Really helpful to log network io
			NSLog(@"\n%@:%@",self.httpMethod,theRequest.URL.absoluteString);
		}
		else {
			
			// Set the url (no query params)
			[theRequest setURL:self.resourceURL];
			
			// Check if need multi-part form
			BOOL hasImage = NO;
			for (id key in self.params) {
				id item = [self.params objectForKey:key];
				if([item isKindOfClass:[UIImage class]]) {
					hasImage = YES;
					break;
				}
			}
			
			if (hasImage) {
				// Multi-part form POST body
				
				NSMutableData *postData = [[NSMutableData alloc] initWithCapacity:0];
				NSString *stringBoundary = @"0xKhTmLbOuNdArY";
				[postData appendData:[[NSString stringWithFormat:@"Content-Type: multipart/form-data; boundary=%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
				NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
				[postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
				
				for (id key in self.params) {
					id item = [self.params objectForKey:key];
					if([item isKindOfClass:[UIImage class]]) {
						// Get the image ready
						UIImage *image = item;//[item imageByScalingAndCroppingForSize:CGSizeMake(1280, 1280)];
						
						// Add image
						[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, @"photo.jpeg" ] dataUsingEncoding:NSUTF8StringEncoding]];
						[postData appendData:[@"Content-Type: image/jpeg\r\n" dataUsingEncoding:NSUTF8StringEncoding]];  // jpeg as data
						[postData appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
						[postData appendData:UIImageJPEGRepresentation(image, 0.9)];  // Tack on the imageData to the end
					}
					else {
						// Add regular parameter
						[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, item] dataUsingEncoding:NSUTF8StringEncoding]];
					}
					[postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
					[postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
				}
				[theRequest setHTTPBody:postData];
				[theRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
			}
			else {
				// Normal POST, PUT, DELETE body
                if (self.params != nil)
                    [theRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:self.params options:0 error:nil]];
               
                [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
			}
			
			// Really helpful to log network io
			//TODO: print json as string
			//NSLog(@"\n%@:%@\n%@",self.httpMethod, theRequest.URL.absoluteString, theRequest );
			// Print just the request URL
			NSLog(@"\n%@:%@",self.httpMethod,theRequest.URL.absoluteString);
		}
		
		
		//Update requests in progress count
		[self performSelectorOnMainThread:@selector(incrementNetworkRequestsInProgress) withObject:nil waitUntilDone:NO];
		
		// Send Request
		NSError *err=nil;
		NSHTTPURLResponse *resp=nil;
		self.response.data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&resp error:&err];
		self.response.systemError = err;
		self.response.httpStatus = resp.statusCode;
		self.response.httpHeaders = resp.allHeaderFields;
		
		//Update requests in progress count
		[self performSelectorOnMainThread:@selector(decrementNetworkRequestsInProgress) withObject:nil waitUntilDone:NO];
		
		// Logging
		if (err) {
			NSLog(@"\n%@", err);
		}
		else {
			// This could be a lot of json
			NSLog(@"\n%i:%@", resp.statusCode, [[NSString alloc] initWithData:self.response.data encoding:NSUTF8StringEncoding]);
			//NSLog(@"\n%i", resp.statusCode);
		}

		
		[self performSelectorOnMainThread:@selector(callFinished) withObject:nil waitUntilDone:NO];		
		
		
		//Custom memory management ;)
		// nil out block? //TODO: Check memory usage
	}
}

- (void)callFinished {
	if (self.finished!=nil) {
		self.finished(self.response);
	}
}


#pragma Network Activity Spinner
static int networkRequestsInProgress_ = 0;
- (void)incrementNetworkRequestsInProgress {
	++networkRequestsInProgress_;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)decrementNetworkRequestsInProgress {
	--networkRequestsInProgress_;
	if (networkRequestsInProgress_<=0) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

#pragma Helpers

+ (NSURL *)urlByAddingQueryStringParams:(NSDictionary *)params toURL:(NSURL *)url {
	NSMutableString *queryString = [NSMutableString string];
	for (id key in params) {
		
		//If array use repeat params
		id theValue = [params objectForKey:key];
		if ([theValue isKindOfClass:[NSArray class]]) {
			for (id valueItem in theValue) {
				
				if (queryString.length==0) {
					[queryString appendFormat:@"?"];
				}
				else {
					[queryString appendFormat:@"&"];
				}
				
				NSString *urlKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				NSString *urlValue = [[valueItem description]
									  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				[queryString appendFormat:@"%@=%@",urlKey,urlValue];
			}
		}
		else {
			//Scalar
			
			if (queryString.length==0) {
				[queryString appendFormat:@"?"];
			}
			else {
				[queryString appendFormat:@"&"];
			}
			
			NSString *urlKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSString *urlValue = [[[params objectForKey:key] description]
								  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
			[queryString appendFormat:@"%@=%@",urlKey,urlValue];
		}
	}
    
	return [NSURL URLWithString:[url.absoluteString stringByAppendingString:queryString]];
}
+(NSString*)stringByDecodingURLFormat:(NSString*)encodedString{
    NSString *result = [encodedString stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}
+ (NSString*)md5:(NSString*)string {
    const char *cStr = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result );
    return [[NSString stringWithFormat:
			 @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			 result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			 result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			 ] lowercaseString];
} 

@end
