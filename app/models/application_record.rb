class ApplicationRecord < ActiveRecord::Base
   protect_from_forgery with: :exception
  
  def hello
    render html: "hello, world!"
  end

end
