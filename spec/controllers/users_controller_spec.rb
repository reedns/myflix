require "spec_helper"

describe UsersController do
  describe "GET new" do
    before { get :new }

    it "assigns a new User to @user" do
      expect(assigns(:user)).to be_a_new(User) 
    end

    it "renders the :new template" do
      expect(response).to render_template :new
    end
  end

  describe "POST create" do
    context "with valid user input and credit card" do
      before do
        charge = double("charge", successful?: true)
        StripeWrapper::Charge.should_receive(:create).and_return(charge)
        post :create, user: Fabricate.attributes_for(:user), token: "123"
      end
          
      it "saves new user to the database", :vcr do
        expect(User.count).to eq(1)
      end

      it "redirects to the home page", :vcr do
        expect(response).to redirect_to home_path
      end

      it "assigns @user variable", :vcr do
        expect(assigns(:user)).to be_instance_of(User)
      end

      it "sets notice", :vcr do
        expect(flash[:notice]).to_not be_blank
      end

      it "puts the user in the session", :vcr do
        expect(session[:user_id]).to eq(User.first.id)
      end

      context "sending email" do
        after { ActionMailer::Base.deliveries.clear }

        it "sends out welcome email", :vcr do
          expect(ActionMailer::Base.deliveries).to_not be_empty
        end

        it "sends email to the correct recipient", :vcr do
          expect(ActionMailer::Base.deliveries.last.to).to eq([User.first.email])
        end

        it "sends email with the correct message", :vcr do
          expect(ActionMailer::Base.deliveries.last.body).to include(User.first.fullname)
        end
      end

      context "registration from an invite" do
        let(:john)  { Fabricate(:user) }
        let(:invite) { Fabricate(:invite, user: john) }
        let(:charge) { double("charge", successful?: true) }
        before { StripeWrapper::Charge.should_receive(:create).and_return(charge) }

        before do
          post :create, user: Fabricate.attributes_for(:user), invite_token: invite.token
          @sally = User.find(3)
        end

        it "creates a following where the user follows the inviter", :vcr do   
          expect(john.followers).to eq([@sally])
        end

        it "creates a following the inviter follows the user", :vcr do
          expect(@sally.followers).to eq([john])
        end

        it "expires the invite after acceptance", :vcr do
          get :new_with_invite_token, token: invite.token
          expect(response).to redirect_to expired_token_path
        end
      end
    end

    context "with invalid user input" do
      after { ActionMailer::Base.deliveries.clear }
      before { post :create, user: { fullname: nil, email: nil, password: nil } }
    
      it "does not save new user to the database", :vcr do
        expect(User.count).to eq(0)
      end

      it "renders the :new template", :vcr do
        expect(response).to render_template  :new
      end

      it "sends out the correct error message" do
        expect(flash[:danger]).to eq("Please fix the errors below.")
      end

      it "does not charge the card" do
        StripeWrapper::Charge.should_not_receive(:create)
      end

      context "sending email", :vcr do
        it "does not send out welcome email" do
          expect(ActionMailer::Base.deliveries).to be_empty
        end
      end
    end 

    context "with valid user input and invalid credit card" do
      after { ActionMailer::Base.deliveries.clear }

      before do
        charge = double('charge', successful?: false)
        charge.stub(:error_message).and_return("Your card was declined.")
        StripeWrapper::Charge.should_receive(:create).and_return(charge)
        post :create, user: Fabricate.attributes_for(:user), token: "123"
      end

      it "does not save the new user to the database", :vcr do
        expect(User.count).to eq(0)
      end

      it "renders the :new template" do
        expect(response).to render_template :new
      end

      it "sends out the credit card error message" do
        expect(flash[:danger]).to eq("Your card was declined.")
      end

      it "does not send out welcome email" do
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end 
  end

  describe "GET show" do
    context "with authenticated user" do
      before do
       set_current_user
       get :show, id: current_user.id
      end

      it "sets the @user variable" do
        expect(assigns(:user)).to eq(current_user)
      end

      it "renders the :show template" do
        expect(response).to render_template :show
      end
    end

    let(:jimbo) { Fabricate(:user) }

    it_behaves_like "require_login" do
      let(:action) { get :show, id: jimbo.id }
    end
  end

  describe "GET new_with_invite_token" do
    let(:invite) { Fabricate(:invite, token: "12345") }
    before { get :new_with_invite_token, token: invite.token }

    it "assigns @user with invitee's email" do
      expect(assigns(:user).email).to eq(invite.friend_email)
    end

    it "assigns a new User to @user" do
      expect(assigns(:user)).to be_a_new(User) 
    end

    it "assigns the @invite_token variable" do
      expect(assigns(:invite_token)).to eq(invite.token)
    end 

    it "renders the :new template" do
      expect(response).to render_template :new
    end

    it "redirects to expired token path if invite doesn't exist" do
      get :new_with_invite_token, token: "abcd"
      expect(response).to redirect_to expired_token_path
    end
  end
end





