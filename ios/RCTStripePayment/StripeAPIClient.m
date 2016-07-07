#import <Foundation/Foundation.h>
#import "StripeAPIClient.h"

@implementation StripeAPIClient
+ (StripeAPIClient*)sharedInit:(NSString*)baseURL customerID:(NSString*)customerID {
    return [StripeAPIClient alloc];
}

- (id)init:(NSString*)baseURL customerID:(NSString*)customerID {
    self = [super init];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = 5;
    self.baseURL = baseURL;
    self.customerID = customerID;
    self.session = [NSURLSession sessionWithConfiguration:configuration];
    return self;
}

- (void)retrieveCustomer:(STPCustomerCompletionBlock)completion {
    NSString *path = [NSString stringWithFormat:@"/customers/%@", self.customerID];
    NSURL *url = [NSURL URLWithString:[self.baseURL stringByAppendingString: path ]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", stringData);
    STPCustomerDeserializer * deserializer = [[STPCustomerDeserializer alloc] initWithJSONResponse:data];
    completion(deserializer.customer, deserializer.error);
}

- (void)selectDefaultCustomerSource:(id<STPSource>)source completion:(STPErrorBlock)completion {
    NSString *path = [NSString stringWithFormat:@"/customers/%@/select_source", self.customerID];
    NSURL *url = [NSURL URLWithString: [self.baseURL stringByAppendingString: path ]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/json" forHTTPHeaderField:@"Content-type"];
    
    NSString *postString = [NSString stringWithFormat:@"source=%@customer=%@", source, self.customerID];
    
    [request setValue:[NSString stringWithFormat:@"%lu", [postString length]] forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self.session dataTaskWithRequest:request
                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        
                        NSString *stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        NSLog(@"%@", stringData);
                        
                        STPCustomerDeserializer * deserializer = [[STPCustomerDeserializer alloc] initWithData:data urlResponse: response error:error];
                        completion(deserializer.error);
                    }];
}

- (void)attachSourceToCustomer:(id<STPSource>)source completion:(STPErrorBlock)completion {
    NSString *path = [NSString stringWithFormat:@"/customers/%@/sources", self.customerID];
    NSURL *url = [NSURL URLWithString: [self.baseURL stringByAppendingString: path ]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/json" forHTTPHeaderField:@"Content-type"];
    
    NSString *postString = [NSString stringWithFormat:@"source=%@customer=%@", source, self.customerID];
    
    [request setValue:[NSString stringWithFormat:@"%lu", [postString length]] forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self.session dataTaskWithRequest:request
                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        
                        NSString *stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        NSLog(@"%@", stringData);
                        
                        STPCustomerDeserializer * deserializer = [[STPCustomerDeserializer alloc] initWithData:data urlResponse: response error:error];
                        completion(deserializer.error);
                    }];
}

@end