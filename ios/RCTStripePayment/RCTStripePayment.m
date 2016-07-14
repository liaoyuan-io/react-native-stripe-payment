#import "RCTStripePayment.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"

@implementation RCTStripePayment

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(setup:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    self.resolve = resolve;
    self.reject = reject;
    
    STPPaymentConfiguration *config = [STPPaymentConfiguration sharedConfiguration];
    [config setPublishableKey: [options valueForKey:@"publishableKey"]];
    [config setRequiredBillingAddressFields:STPBillingAddressFieldsFull];
    [config setSmsAutofillDisabled:YES];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = 5;
    self.baseURL = [options valueForKey:@"baseUrl"];
    self.session = [NSURLSession sessionWithConfiguration:configuration];
    self.authHeader = [options valueForKey:@"authHeader"];
    self.paymentContext = [[STPPaymentContext alloc] initWithAPIAdapter:self];
    
    STPUserInformation *userInfo = [[STPUserInformation alloc] init];
    userInfo.email = [options valueForKey:@"email"];
    [self.paymentContext setPrefilledInformation: userInfo];
    self.paymentContext.delegate = self;
    UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    self.paymentContext.hostViewController = root;
    
    self.resolve(@{});
}

RCT_EXPORT_METHOD(selectPayment:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    self.resolve = resolve;
    self.reject = reject;
    self.changeDefault = NO;
    
    [self.paymentContext presentPaymentMethodsViewController];
}


RCT_EXPORT_METHOD(selectDefaultPayment:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    self.resolve = resolve;
    self.reject = reject;
    self.changeDefault = YES;
    
    [self.paymentContext presentPaymentMethodsViewController];
}

RCT_EXPORT_METHOD(addPayment:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    self.resolve = resolve;
    self.reject = reject;
    
    STPPaymentContext * paymentContext = self.paymentContext;
    STPAddCardViewController *addCardViewController = [[STPAddCardViewController alloc] initWithConfiguration:paymentContext.configuration theme:paymentContext.theme];
    addCardViewController.delegate = paymentContext;
    addCardViewController.prefilledInformation = paymentContext.prefilledInformation;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addCardViewController];
    [navigationController.navigationBar stp_setTheme:paymentContext.theme];
    [paymentContext.hostViewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)paymentContextDidChange:(STPPaymentContext *)paymentContext {}

- (void)paymentContext:(STPPaymentContext *)paymentContext didCreatePaymentResult:(STPPaymentResult *)paymentResult completion:(STPErrorBlock)completion {
    self.resolve(@{ @"source" : [[paymentResult source] stripeID]});
}

- (void)paymentContext:(STPPaymentContext *)paymentContext didFinishWithStatus:(STPPaymentStatus)status error:(NSError *)error {
}

- (void)paymentContext:(STPPaymentContext *)paymentContext didFailToLoadWithError:(NSError *)error {
    [self.paymentContext.hostViewController dismissViewControllerAnimated:YES completion:nil];
    self.reject(@"fail_load_customer", @"Failed to load customer", error);
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
    if(!self.changeDefault) {
        completion(nil);
        self.resolve(@{ @"source" : [source stripeID] });
        return;
    }
    NSString *path = @"/source";
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{ @"source" : [source stripeID] }
                                                   options:NSJSONWritingPrettyPrinted error:nil];
    
    [self put:path withData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error != nil) { completion(error); return;}
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        if(httpResponse.statusCode == 200) {
            completion(nil);
            self.resolve(@{ @"source" : [source stripeID] });
        }
        else completion([NSError errorWithDomain:@"选择支付方式失败" code:httpResponse.statusCode userInfo:nil]);
    }];
}

- (void)attachSourceToCustomer:(id<STPSource>)source completion:(STPErrorBlock)completion {
    NSString *path = @"/source";
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{ @"token" : [source stripeID] }
                                                   options:NSJSONWritingPrettyPrinted error:nil];
    
    [self post:path withData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error != nil) { completion(error); return;}
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        if(httpResponse.statusCode == 200) {
            completion(nil);
        }
        else completion([NSError errorWithDomain:@"添加支付方式失败" code:httpResponse.statusCode userInfo:nil]);
    }];
}

- (void)put:(NSString*)path withData:(NSData*)data completionHandler:(void(^)(NSData *data, NSURLResponse *response, NSError *error))handler{
    NSURL *url = [NSURL URLWithString: [self.baseURL stringByAppendingString: path ]];
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
#ifdef DEBUG
    NSLog(@"put url: %@ with %@ %@", url, self.authHeader, dataString);
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