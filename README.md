# rails aes to column

## Setting

Create `config/lib/aes.rb` :
```ruby
module AesEncryptDecrypt
	KEY = "加密ＫＥＹ"
	IV = "加密ＩＶ"

	def self.encryption(msg)
		begin
			cipher = OpenSSL::Cipher::AES256.new(:CBC)#OpenSSL::Cipher::AES.new(128, :CBC)
			cipher.encrypt
			cipher.key = KEY
			cipher.iv = IV
			encrypted = cipher.update(msg) + cipher.final
			#crypt_string = encrypted
			crypt_string =(Base64.encode64(encrypted))
			return crypt_string
		rescue Exception => exc
			puts ("Message for the encryption log file for message #{msg} = #{exc.message}")
			return nil
		end
	end

	def self.decryption(msg)
		begin
			decipher = OpenSSL::Cipher::AES256.new(:CBC)#OpenSSL::Cipher::AES.new(128, :CBC)
			decipher.decrypt
			decipher.key = KEY
			decipher.iv = IV
			#temp_msg = msg
			temp_msg = Base64.decode64(msg)
			plain = decipher.update(temp_msg) + decipher.final
			return plain.force_encoding('UTF-8')
		rescue Exception => exc
			puts ("Message for the decryption log file for message #{msg} = #{exc.message}")
			return nil
		end
	end

end
```

Create `config/initializers/aes_require.rb` :
```ruby
require 'aes'

class ActiveRecord::Base

  #model 增加 self.aes_attributes 方法
  def self.aes_attributes(*columns)

    columns.each do |column|
      define_method "#{column}_decrypt".to_sym do
        if send(column.to_s).blank?
          return nil
        end
        if self.attribute_names.include?(column.to_s)
          @decrypt_cache ||= {}
          return @decrypt_cache[column] ||= (AesEncryptDecrypt.decryption(send(column.to_s)) || "編碼發生錯誤")
        else
          raise "No this method!"
        end
      end
    end

    before_save do
      columns.each do |column|
        if self.try("#{column}_changed?") && !self.try("#{column}").blank? && self.attribute_names.include?("#{column}")
          crypt =  AesEncryptDecrypt.encryption(try(column))
          if crypt && AesEncryptDecrypt.decryption(crypt) #確認可加解密才存入
            self.send "#{column}=", crypt
            @decrypt_cache ||= {}
            @decrypt_cache[column] = nil #有更新後，清除快取
          else
            errors.add(column, "skip because #{column} encode faild")
            return false
          end
        end
      end
    end

  end

end
```

And then in Model:
```ruby
class Member < ActiveRecord::Base
  aes_attributes :name, :id_number, :addres #需要被加解密的attributes
end

```

## example

```bash
	member = Member.new
	member.name='name'
	member.id_number='1234567890'
	member.addres='Taiwan'
	member.save

	(then...)

	member.name = "45Td1fWMNRPzttuolOiIWQ==\n"
	member.name_decrypt = "name"
```

