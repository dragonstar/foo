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
      visit root_url
      page.should have_content("Edit Account")
      click_link "Edit Account"
      select "Extreme", from: 'Plan'
      click_button "Update Account"
      page.should have_content("Account updated successfully.")
      page.should have_content("You are now on the 'Extreme' plan.")
      account.reload.plan.should == extreme_plan
    end
  end
end