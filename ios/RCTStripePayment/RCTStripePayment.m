#import "RCTStripePayment.h"

@implementation RCTStripePayment

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(selectPayment:(NSDictionary *)options) {
    /*  TODO:
     *  prefilledInformation
     *  in options
     */
    [[STPPaymentConfiguration sharedConfiguration] setPublishableKey: [options valueForKey:@"publishableKey"]];
    StripeAPIClient *client = [StripeAPIClient sharedInit: [options valueForKey:@"baseUrl"] withAuthHeader: [options valueForKey:@"authHeader"]];
    self.paymentContext = [[STPPaymentContext alloc] initWithAPIAdapter:client];
    self.paymentContext.delegate = self;
    UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    self.paymentContext.hostViewController = root;
    
    [self.paymentContext presentPaymentMethodsViewController];
}

RCT_EXPORT_METHOD(requestPayment:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    self.resolve = resolve;
    self.reject = reject;
    [self.paymentContext requestPayment];
}

- (void)paymentContextDidChange:(STPPaymentContext *)paymentContext {
    NSLog(@"paymentContext %@", [paymentContext selectedPaymentMethod]);
}

- (void)paymentContext:(STPPaymentContext *)paymentContext didCreatePaymentResult:(STPPaymentResult *)paymentResult completion:(STPErrorBlock)completion {
    NSLog(@"paymentResult %@");
    self.resolve([[paymentResult source] stripeID]);
}

- (void)paymentContext:(STPPaymentContext *)paymentContext didFinishWithStatus:(STPPaymentStatus)status error:(NSError *)error {
    NSLog(@"didFinishWithStatus %@");
}

- (void)paymentContext:(STPPaymentContext *)paymentContext didFailToLoadWithError:(NSError *)error {
    self.reject(@"fail_load_customer", @"Failed to load customer",error);
}

@end
