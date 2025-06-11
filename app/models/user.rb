class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  after_create :send_signup_email

  devise :database_authenticatable,
         :registerable,
          :recoverable,
          :rememberable,
          :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self
         
  has_many :clients, dependent: :destroy
  has_one :setting, dependent: :destroy
  has_one_attached :avatar

  validates :name, presence: true, uniqueness: true

  # before_save :resize_avatar

  # private

  # # Note: AbcSize: 21.47
  # def resize_avatar
  #   # Loop through attached files
  #   # avatar do |index|
  #     # Ignore previously saved attachments
  #   if avatar.persisted?

  #     # The real uploaded file (in my case, a Rack::Test::UploadedFile)
  #     # This is an undocumented Rails API, so it may change or break in future updates
  #     file = attachment_changes['avatar']

  #     # Resize and override original file
  #     processed = ImageProcessing::Vips.source(file.path)
  #                                      .resize_to_limit!(400, 400)
  #     FileUtils.mv processed, file.path

  #     # Update the ActiveStorage::Attachment's checksum and other data.
  #     # Check ActiveStorage::Blob#unfurl
  #     avatar.unfurl processed
  #   end
  # end
   
  private

    def send_signup_email
      UserMailer.signup_email(self).deliver_later # or deliver_later
    end
end
