# This migration comes from subscribem (originally 20140912064829)
class AddPlanIdToSubscribemAccounts < ActiveRecord::Migration
  def change
    add_column :subscribem_accounts, :plan_id, :integer
  end
end
