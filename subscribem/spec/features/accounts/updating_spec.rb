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
      fill_in "Name", with: "A new name"
      click_button "Update Account"
      page.should have_content("Account updated successfully.")
      account.reload.name.should == "A new name"
    end
  end
end