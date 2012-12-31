async-http-client-ios
=====================

Asynchronous Http Client for iOS

This code was built by my mentor and good friend Jeff DiTullio.  I am currently in the middle of writing an eBook on a to be announced project, and wanted to open source this code.

It is a iOS style version of the wonderful async-http-client code written for Java.  I actually used this code in projects first, and then found the one in java when I started developing for Android.  Jeff is a rockstar, and this code has helped me throughout many projects, so hopefully it will be helpful to you all as well.

Below is a really simple sample of using the code.  I will upload a sample application shortly that shows a few more use cases.

Example Setup
=====================

For the example, I am using mongo labs as it is free and gives you a built in api, for testing both the gets and the posts.

To run the example, you should

1. signup for a free account on MongoLab
2. download this repo 
3. go into the Config.h file and set your mongo database and mongo api key.
4. run the app, and press the Add Item and you can see it adds it to your mongo db, press the Get Items button, and the console will show the api payload.

You can also just change the code to point to any api of your choosing.  I will expand on this soon.

Sample Usage (Pseudo code mostly)
=====================

SampleViewController.m

import "WebServiceResponse.h"

- (void)viewDidLoad {
  [ItemModel getItems:^(WebServiceResponse* response){
    if (!response.systemError) {
      self.items = [ItemModel loadItemsFromDictionary:response.dictionary];
    }
  }]
}

ItemModel.m

import "WebServiceResponse.h"
import "WebServiceRequest.h"

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
