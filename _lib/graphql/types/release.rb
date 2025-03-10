class UbiquityGraphQL::Types::Release < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: false
  field :avatar, Types::PhotoType
end