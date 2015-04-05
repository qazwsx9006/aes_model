class Member < ActiveRecord::Base
  aes_attributes :name, :id_number, :addres #需要被加解密的attributes
end
