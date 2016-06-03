module BibCard
  class EntityNotFoundException < RuntimeError

    MESSAGE = 'Entity not found.'

    def initialize
      super MESSAGE
    end

  end
end