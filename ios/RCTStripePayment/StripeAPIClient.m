#import <Foundation/Foundation.h>
#import "StripeAPIClient.h"

@implementation StripeAPIClient
+ (StripeAPIClient*)sharedInit:(NSString*)baseURL withAuthHeader:(NSString*) authHeader{
    return [[StripeAPIClient alloc] init:baseURL withAuthHeader:authHeader];
}

- (id)init:(NSString*)baseURL withAuthHeader:(NSString*) authHeader {
    self = [super init];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = 5;
    self.baseURL = baseURL;
    self.session = [NSURLSession sessionWithConfiguration:configuration];
    self.authHeader = authHeader;
    return self;
}

- (void)retrieveCustomer:(STPCustomerCompletionBlock)completion {
    NSString *path = @"/customer";
    [self get:path completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        STPCustomerDeserializer * deserializer = [[STPCustomerDeserializer alloc] initWithData:data urlResponse: response error:error];
        self.customerID = deserializer.customer.stripeID;
        completion(deserializer.customer,deserializer.error);
    }];
}

- (void)selectDefaultCustomerSource:(id<STPSource>)source completion:(STPErrorBlock)completion {
    NSString *path = @"/customer/select_source";
    NSString *postString = [NSString stringWithFormat:@"source=%@customer=%@", source, self.customerID];
    
    [self post:path withPostData:postString completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        STPCustomerDeserializer * deserializer = [[STPCustomerDeserializer alloc] initWithData:data urlResponse: response error:error];
        completion(deserializer.error);
    }];
}

- (void)attachSourceToCustomer:(id<STPSource>)source completion:(STPErrorBlock)completion {
    NSString *path = @"/customer/sources";
    NSString *postString = [NSString stringWithFormat:@"source=%@customer=%@", source, self.customerID];
    
    [self post:path withPostData:postString completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        STPCustomerDeserializer * deserializer = [[STPCustomerDeserializer alloc] initWithData:data urlResponse: response error:error];
        completion(deserializer.error);
    }];
}

- (void)post:(NSString*)path withPostData:(NSString*)postData completionHandler:(void(^)(NSData *data, NSURLResponse *response, NSError *error))handler{
    NSURL *url = [NSURL URLWithString: [self.baseURL stringByAppendingString: path ]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:[NSString stringWithFormat:@"%lu", [postData length]] forHTTPHeaderField:@"Content-length"];
    [request setValue:self.authHeader forHTTPHeaderField:@"Authorization"];
    
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self.session dataTaskWithRequest:request completionHandler:handler];
}


- (void)get:(NSString*)path completionHandler:(void(^)(NSData *data, NSURLResponse *response, NSError *error))handler{
    NSURL *url = [NSURL URLWithString: [self.baseURL stringByAppendingString: path ]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"text/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:self.authHeader forHTTPHeaderField:@"Authorization"];
    
    [self.session dataTaskWithRequest:request completionHandler:handler];
}

@end