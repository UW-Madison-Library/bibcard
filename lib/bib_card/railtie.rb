module BibCard
  # Add support for rails logging
  class Railtie < Rails::Railtie
    initializer 'Rails logger' do
      BibCard.logger = Rails.logger
    end
  end
end