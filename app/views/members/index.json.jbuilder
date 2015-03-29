json.array!(@members) do |member|
  json.extract! member, :id, :name, :id_number, :addres
  json.url member_url(member, format: :json)
end
