require 'spec_helper'

describe StripeWrapper do
  describe StripeWrapper::Charge do
    before { StripeWrapper.api_key }

    describe ".create" do
      let(:token) do 
        Stripe::Token.create(
          "card" => {
              "number" => card_number,
              "exp_month" => 8,
              "exp_year" => 2018,
              "cvc" => "314"
          }
        ).id
      end

      context "with valid credit card" do
        let(:card_number) { "4242424242424242" }
        it "charges the credit card", :vcr do
          response = StripeWrapper::Charge.create(amount: 999, card: token, description: "A valid charge")
          expect(response.successful?).to be_true
        end
      end
      
      context "with invalid credit card" do
        let(:card_number) { "4000000000000002" }
        let(:response) { StripeWrapper::Charge.create(amount: 999, card: token, description: "An invalid charge") }

        it "does not charge the credit card", :vcr do
          expect(response.successful?).to be_false
        end

        it "sets the error message", :vcr do
          expect(response.error_message).to eq("Your card was declined.")
        end
      end
    end
  end
end
