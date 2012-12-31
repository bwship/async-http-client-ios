//
//  WebServiceResponse.h
//  async-http-client-ios
//
//  Created by Jeff DiTullio on 9/22/12.
//


#import <Foundation/Foundation.h>

@interface WebServiceResponse : NSObject

@property (nonatomic,readonly) BOOL success;			//http success, 200's
@property (nonatomic,readonly) BOOL successDictionary;	//http success, 200's; and parsed JSON.
@property (nonatomic,readonly) BOOL didTimeout;

@property (nonatomic,strong) NSDictionary *httpHeaders;
@property (nonatomic) NSInteger httpStatus;				//http errors
@property (nonatomic,strong) NSError *systemError;		//network/system errors

@property (nonatomic,strong) NSData *data;
@property (nonatomic,strong,readonly) NSDictionary *dictionary;

@end
