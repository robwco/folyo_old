class ConversationsController < ApplicationController

  def create
    conversation = Conversation.find_or_initialize_by(designer_reply_id: conversation_params[:designer_reply_id])
    add_message(conversation)
  end

  def update
    conversation = Conversation.find_by(designer_reply_id: conversation_params[:designer_reply_id])
    add_message(conversation)
  end

  protected

  def add_message(conversation)
    conversation.messages << Message.new(text: message_params[:text], author: current_user)
    conversation.save!
  end

  def conversation_params
    params[:conversation].permit(:designer_reply_id)
  end

  def message_params
    params[:message].permit(:text)
  end

end
