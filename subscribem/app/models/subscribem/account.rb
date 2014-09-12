module Subscribem
  class Account < ActiveRecord::Base
    validates :subdomain, :presence => true, :uniqueness => true
    validates :name, :presence => true

    EXCLUDED_SUBDOMAINS = %w(admin)
    validates_exclusion_of :subdomain, :in => EXCLUDED_SUBDOMAINS, :message => "is not allowed.  Please choose another subdomain."
    validates_format_of :subdomain, with: /\A[\w\-]+\z/i, :message => "is not allowed. Please choose another subdomain"


    belongs_to :owner, :class_name => "Subscribem::User"
    belongs_to :plan, :class_name => "Subscribem::Plan"
    accepts_nested_attributes_for :owner
    has_many :members, :class_name => "Subscribem::Member"
    has_many :users, :through => :members


    before_validation do
      self.subdomain = subdomain.to_s.downcase
    end

    #def create_schema
    #  Apartment::Database.create(subdomain)
    #end

    def self.create_with_owner(params={})
      account = new(params)
      if account.save
         account.users << account.owner
      end
      account
    end

    def owner?(user)
      owner == user
    end



  end
end
