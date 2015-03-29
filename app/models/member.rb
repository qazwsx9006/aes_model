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
