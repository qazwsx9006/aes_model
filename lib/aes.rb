# encoding: utf-8

require 'openssl'
require 'base64'

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