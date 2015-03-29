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
```

And then in Model:
```ruby
class Member < ActiveRecord::Base
  before_save :aes
  @@aes_column = [:name, :id_number, :addres] #需要被加解密的attribute


  def aes
    @@aes_column.each do |attr|
      if self.try("#{attr}_changed?") && !self.try("#{attr}").blank? && self.attribute_names.include?("#{attr}") && @@aes_column.include?(attr)
        crypt =  AesEncryptDecrypt.encryption(try(attr))
        if crypt && AesEncryptDecrypt.decryption(crypt) #確認可加解密才存入
          self.send "#{attr}=", crypt
        else
          errors.add(attr, "skip because #{attr} encode faild")
          return false
        end
      end
    end
  end

  #自動生成 *_decrypt 方法
  def method_missing(method_name)
    # delegate to superclass if you're not handling that method_name
    return super unless /^(.*)_decrypt$/ =~ method_name

    if self.attribute_names.include?($1) && @@aes_column.include?($1.to_sym)
      AesEncryptDecrypt.decryption(send($1)) || "編碼發生錯誤"
    else
      raise "No this method!"
    end
  end

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

