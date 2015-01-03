require 'digest'
class User < ActiveRecord::Base
  #This creates an accessor (variable) that will allow you to set the password before it's encrypted
  #Remember, there is no "password" column on your database.
  attr_accessor :password
  validates_uniqueness_of :email 
  validates_length_of :email, within: 5..50 
  validates_format_of :email, :with => /^[^@][\w.-]+@[\w.-]+[.][a-z]{2,4}$/i, :multiline => true
  validates_confirmation_of :password
  validates_length_of :password, within: 4..20
  validates_presence_of :password, :if => :password_required?

  has_one :profile
  has_many  :articles, -> { order('published_at DESC, title ASC')}, :dependent => :nullify
  has_many :replies, :through => :articles, :source => :comments

  before_save :encrypt_new_password

  #This is a class method because "self" defined in the method name is meant to be called on the class itself. That means you don't access
  #it via an instance; you access it directly off the class, just as you would find, new, or create
  def self.authenticate(email, password)
    user = find_by_email(email)
    return user if user && user.authenticated?(password)
  end

  #This is a simple predicate method that checks to make sure the stored hashed_password
  #matches the given password after it has been encrypted (via encrypt).
  # if it matches, "true" is returned.
  def authenticated?(password)
    self.hashed_password == encrypt(password)
  end

  protected
    #encrypts password only if password accessor isn't blank.
    def encrypt_new_password
      return if password.blank?
      self.hashed_password = encrypt(password)
    end

    #this is a predicate method that returns true if a password is required or false if it isn't
    #this method is applied as an :if condition on all your password validators
    #it's required only if this is a new record (the hashed_password attribute is blank)
    #or if the password accessor you created has been used to set a new password (password.present?)
    def password_required?
      hashed_password.blank? || password.present?
    end

    def encrypt(string)
      Digest::SHA1.hexdigest(string)
    end

end
