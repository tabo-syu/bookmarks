class DiscordRecipientsController < ApplicationController
  def index
    @recipients = DiscordRecipient.order(created_at: :desc).all
  end

  # Create
  def new
    @recipient = DiscordRecipient.new
  end

  def create
    @recipient = DiscordRecipient.new(discord_recipient_params)

    if @recipient.save
      redirect_to discord_recipients_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def discord_recipient_params
    params.require(:discord_recipient).permit(:channel_id, tag_ids: [])
  end
end
