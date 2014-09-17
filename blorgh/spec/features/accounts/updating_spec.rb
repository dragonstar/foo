require "spec_helper"
require "subscribem/testing_support/factories/account_factory"
require "subscribem/testing_support/authentication_helpers"

feature "Accounts" do
  include Subscribem::TestingSupport::AuthenticationHelpers
  let(:account) { FactoryGirl.create(:account) }
  let(:root_url) {"http://#{account.subdomain}.example.com/"}

  context "as the account owner" do
    before do
      sign_in_as(user: account.owner, account: account)
    end

    scenario "updating an account" do
      visit root_url
      click_link "Edit Account"
      page.should have_content("Name")
      fill_in "Name", with: "A new name"
      click_button "Update Account"
      page.should have_content("Account updated successfully.")
      account.reload.name.should == "A new name"
    end

    scenario "updating an account with invalid attribute fails" do
      visit root_url
      click_link "Edit Account"
      fill_in "Name", with: ""
      click_button "Update Account"
      page.should have_content("Name can't be blank")
      page.should have_content("Account could not be update")
    end
  end

  context "as a user" do
    before do
      user = FactoryGirl.create(:user)
      sign_in_as(user: user, account: account)
    end
    scenario "cannot edit an account's information" do
      visit subscribem.edit_account_url(:subdomain => account.subdomain)
      page.should have_content("You are not allowed to do that")
    end
  end

  context "with plans" do
    let!(:starter_plan) do
      Subscribem::Plan.create(
          name: "Starter",
          price: 9.95,
          braintree_id: "starter"
      )
    end
    let!(:extreme_plan) do
      Subscribem::Plan.create(
          name: "Extreme",
          price: 19.95,
          braintree_id: 'extreme'
      )
    end
    before do
      account.update_column(:plan_id, starter_plan.id)
      sign_in_as(user: account.owner, account: account)
    end
    scenario "updating an account's plan" do
      subscription_params = {
          :payment_method_token => "abcdef",
          :plan_id => extreme_plan.braintree_id
      }
      Braintree::Subscription.should_receive(:create).
          with(subscription_params).
          and_return(double(:success? => true))
      query_string = Rack::Utils.build_query(
          :plan_id => extreme_plan.id,
          :http_status => 200,
          :id => "a_fake_id",
          :kind => "create_customer",
          :hash => "0dcae8afb077971f673ecb656a35159c7f000162"
      )
      mock_transparent_redirect_response = double(:success? => true)
      mock_transparent_redirect_response.stub_chain(:customer,
          :credit_cards).
          and_return([double(:token => "abcdef")])
      Braintree::TransparentRedirect.
          should_receive(:confirm).with(query_string).
          and_return(mock_transparent_redirect_response)
      visit root_url
      page.should have_content("Edit Account")
      click_link "Edit Account"
      select "Extreme", from: 'Plan'
      click_button "Update Account"
      page.should have_content("Account updated successfully.")
      plan_url = subscribem.plan_account_url(
          :plan_id => extreme_plan.id,
          :subdomain => account.subdomain
      )
      page.current_url.should == plan_url
      #page.should have_content("You are now on the 'Extreme' plan.")
      #account.reload.plan.should == extreme_plan
      page.should have_content("You are changing to the 'Extreme' plan")
      page.should have_content("This plan costs $19.95 per month")
      fill_in "Credit card number", with: "4111111111111111"
      fill_in "Name on card", with: "Dummy user"
      future_date = "#{Time.now.month + 1}/#{Time.now.year + 1}"
      fill_in "Expiration date", with: future_date
      fill_in "CVV", with: "123"
      click_button "Change plan"
      page.should have_content("You have switched to the 'Extreme' plan.")
      page.current_url.should == root_url

    end
  end
end