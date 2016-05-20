module BibCard
  class Person < Spira::Base
    
    def uri
      self.subject
    end
    
  end
end