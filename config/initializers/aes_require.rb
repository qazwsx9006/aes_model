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