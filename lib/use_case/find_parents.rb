module UseCase
  class FindParents
    def initialize(
      addresses_gateway:
    )
      @addresses_gateway = addresses_gateway
    end

    def execute(uprns:)
      uprns.uniq!
      @addresses_gateway.search_by_uprns(uprns:)
    end
  end
end
