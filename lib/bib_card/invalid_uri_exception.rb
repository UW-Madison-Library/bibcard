module BibCard
  class InvalidURIException < RuntimeError

    MESSAGE = 'Invalid URI. BibCard requires a valid VIAF or LCNAF URI.'

    def initialize
      super MESSAGE
    end

  end
end