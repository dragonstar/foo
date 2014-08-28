class Thing < ActiveRecord::Base
  scoped_to_account

  extend Subscribem::ScopedTo
end
