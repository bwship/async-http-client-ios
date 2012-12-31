async-http-client-ios
=====================

Asynchronous Http Client for iOS

This code was built by my mentor and good friend Jeff DiTullio.  I am currently in the middle of writing an eBook on a to be announced project, and wanted to open source this code.

It is a iOS style version of the wonderful async-http-client code written for Java.  I actually used this code in projects first, and then found the one in java when I started developing for Android.  Jeff is a rockstar, and this code has helped me throughout many projects, so hopefully it will be helpful to you all as well.

Below is a really simple sample of using the code.  I will upload a sample application shortly that shows a few more use cases.

Sample Usage
=====================

SampleViewController.m

#import "WebServiceResponse.h"

- (void)viewDidLoad {
  [ItemModel getItems:^(WebServiceResponse* response){
    if (!response.systemError) {
      self.items = [ItemModel loadItemsFromDictionary:response.dictionary];
    }
  }]
}

ItemModel.m

#import "WebServiceResponse.h"
#import "WebServiceRequest.h"

/* restful api call to get items for the specified category */
+ (WebServiceResponse*)getItems:(WebServiceCallbackBlock)finished {
  WebServiceRequest *request = [WebServiceRequest new];
	request.resourceURL = [NSURL URLWithString:@"http:www.test.com/apiEndpoint"];
        
  request.params = [NSDictionary dictionaryWithObjectsAndKeys:
                          TEST_API_KEY, @"apiKey",
                                 @"10", @"limit",
                                 nil];
    
	request.httpMethod = kHTTPMethodGet;
	
	return [request doRequestFinished:finished];
}
