package io.liaoyuan.reactnative.stripepayment;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

import com.stripe.android.*;
import com.stripe.android.model.Card;
import com.stripe.android.model.Token;
import com.stripe.exception.AuthenticationException;

public class StripePayment extends ReactContextBaseJavaModule{

    private static final String E_INVALID_PK = "E_INVALID_PK";
    private static final String E_CARD_NUMBER_NOT_VALID = "E_CARD_NUMBER_NOT_VALID";
    private static final String E_CARD_EXP_DATE_NOT_VALID = "E_CARD_EXP_DATE_NOT_VALID ";
    private static final String E_CARD_CVC_NOT_VALID = "E_CARD_CVC_NOT_VALID";

    public StripePayment(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "StripePayment";
    }

    @ReactMethod
    public void getToken(ReadableMap cardInfo, final Promise promise) {
        try{

            String publicKey = cardInfo.getString("publicKey");

            Stripe stripe = new Stripe(publicKey);

            String number = cardInfo.getString("number");
            int expMonth = cardInfo.getInt("expMonth");
            int expYear = cardInfo.getInt("expYear");
            String cvc = cardInfo.getString("cvc");

            Card card = new Card.Builder(number, expMonth, expYear, cvc)
                    .name(cardInfo.getString("name"))
                    .addressLine1(cardInfo.getString("addressLine1"))
                    .addressLine2(cardInfo.getString("addressLine2"))
                    .addressCity(cardInfo.getString("city"))
                    .addressState(cardInfo.getString("state"))
                    .addressZip(cardInfo.getString("zip"))
                    .addressCountry(cardInfo.getString("country"))
                    .build();

            if (!card.validateNumber()) {
                promise.reject(E_CARD_NUMBER_NOT_VALID, "卡号有误");
                return;
            }

            if (!card.validateExpiryDate()) {
                promise.reject(E_CARD_EXP_DATE_NOT_VALID, "有效日期有误");
                return;
            }

            if (!card.validateCVC()) {
                promise.reject(E_CARD_CVC_NOT_VALID, "安全码有误");
                return;
            }

            stripe.createToken(card,
                    new TokenCallback() {
                        @Override
                        public void onError(Exception error) {
                            promise.reject(error);
                        }

                        @Override
                        public void onSuccess(Token token) {
                            promise.resolve(token);
                        }
                    });

        } catch(AuthenticationException e) {
            promise.reject(E_INVALID_PK, "Invalid public key");
        }
    }
}