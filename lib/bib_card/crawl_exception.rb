module BibCard
  class CrawlException < RuntimeError

    def initialize(message = "")
      super message
    end

  end
end