#import "RCTStripePayment.h"

@implementation RCTStripePayment

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(selectPayment:(NSDictionary *)options) {
    STPPaymentConfiguration *config = [STPPaymentConfiguration sharedConfiguration];
    [config setPublishableKey: [options valueForKey:@"publishableKey"]];
    [config setRequiredBillingAddressFields:STPBillingAddressFieldsFull];
    StripeAPIClient *client = [StripeAPIClient sharedInit: [options valueForKey:@"baseUrl"] withAuthHeader: [options valueForKey:@"authHeader"]];
    self.paymentContext = [[STPPaymentContext alloc] initWithAPIAdapter:client];
    self.paymentContext.delegate = self;
    UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    self.paymentContext.hostViewController = root;
    
    [self.paymentContext presentPaymentMethodsViewController];
}

- (void)paymentContextDidChange:(STPPaymentContext *)paymentContext {}

- (void)paymentContext:(STPPaymentContext *)paymentContext didCreatePaymentResult:(STPPaymentResult *)paymentResult completion:(STPErrorBlock)completion {
    self.resolve(@{@"source" : [[paymentResult source] stripeID]});
}

- (void)paymentContext:(STPPaymentContext *)paymentContext didFinishWithStatus:(STPPaymentStatus)status error:(NSError *)error {
    @throw [[NSError alloc] initWithDomain:@"DID_FINISH_WITH_STATUS_CALLED" code:@"100" userInfo:nil];
}

- (void)paymentContext:(STPPaymentContext *)paymentContext didFailToLoadWithError:(NSError *)error {
    self.reject(@"fail_load_customer", @"Failed to load customer",error);
}

@end