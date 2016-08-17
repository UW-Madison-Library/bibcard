module BibCard
  class EntityNotFoundException < RuntimeError

    MESSAGE = 'Entity not found.'

    def initialize(custom_msg = nil)
      custom_msg.nil? ? super(MESSAGE) : super(custom_msg)
    end

  end
end