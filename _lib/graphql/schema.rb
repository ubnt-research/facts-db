require 'graphql'

module UbiquityGraphQL
  class Schema < GraphQL::Schema
    max_complexity 400
    query Types::Query
    use GraphQL::Dataloader

  end
end