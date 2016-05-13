class UserMailer < ApplicationMailer
  def download_track(user_id, track_code)
    @user = User.find_by_id(user_id)
    @track = Track.find_by_code(track_code)

    return unless @user && @track && @track.track_items.any?
    @track.get_data.each { |file| attachments[file[:name]] = file[:content] }

    mail to: @user.email, subject: "#{I18n.t('title')}: #{@track.name}"
  end

  def new_user(user_id)
    @user = User.find_by_id(user_id)

    mail_to_admins "#{I18n.t('title')}: #{I18n.t('mailer.new_user.subj')}" if @user
  end
end
