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
    NSString *path = @"/source";
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{ @"source" : [source stripeID] }
                                                   options:NSJSONWritingPrettyPrinted error:nil];
    
    [self put:path withData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(((NSHTTPURLResponse*)response).statusCode == 200) completion(nil);
        else completion(error);
    }];
}

- (void)attachSourceToCustomer:(id<STPSource>)source completion:(STPErrorBlock)completion {
    NSString *path = @"/source";
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{ @"token" : [source stripeID] }
                                                   options:NSJSONWritingPrettyPrinted error:nil];
    
    [self post:path withData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(((NSHTTPURLResponse*)response).statusCode == 200) completion(nil);
        else completion(error);
    }];
}

- (void)put:(NSString*)path withData:(NSData*)data completionHandler:(void(^)(NSData *data, NSURLResponse *response, NSError *error))handler{
    NSURL *url = [NSURL URLWithString: [self.baseURL stringByAppendingString: path ]];
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
#ifdef DEBUG
    NSLog(@"post url: %@ with %@ %@", url, self.authHeader, dataString);
#endif
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:[NSString stringWithFormat:@"%lu", [data length]] forHTTPHeaderField:@"Content-length"];
    [request setValue:self.authHeader forHTTPHeaderField:@"Authorization"];
    
    [request setHTTPBody:data];
    
    NSURLSessionTask *task= [self.session dataTaskWithRequest:request completionHandler:handler];
    [task resume];
}

- (void)post:(NSString*)path withData:(NSData*)data completionHandler:(void(^)(NSData *data, NSURLResponse *response, NSError *error))handler{
    NSURL *url = [NSURL URLWithString: [self.baseURL stringByAppendingString: path ]];
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
#ifdef DEBUG
    NSLog(@"post url: %@ with %@ %@", url, self.authHeader, dataString);
#endif
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    [request setValue:[NSString stringWithFormat:@"%lu", [dataString length]] forHTTPHeaderField:@"Content-length"];
    [request setValue:self.authHeader forHTTPHeaderField:@"Authorization"];
    
    [request setHTTPBody:data];
    
    NSURLSessionTask *task= [self.session dataTaskWithRequest:request completionHandler:handler];
    [task resume];
}


- (void)get:(NSString*)path completionHandler:(void(^)(NSData *data, NSURLResponse *response, NSError *error))handler{
    NSURL *url = [NSURL URLWithString: [self.baseURL stringByAppendingString: path ]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:self.authHeader forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask *task= [self.session dataTaskWithRequest:request completionHandler:handler];
    [task resume];
}

@end