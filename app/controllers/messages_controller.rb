class MessagesController < ApplicationController

  def index
    @messages = Message.all
    render json: @messages
  end

  def create
    if params.has_key?(:sdp)
      ActionCable.server.broadcast "messages_channel", message_params
    else
      message = Message.new(message_params)
      conversation = Conversation.find(message_params[:conversation_id])
        if message.save
      # byebug
        serialized_data = ActiveModelSerializers::Adapter::Json.new(
          MessageSerializer.new(message)
        ).serializable_hash
        MessagesChannel.broadcast_to conversation, serialized_data
        head :ok
      end
    end
  end

  private

  def message_params
    params.permit(:text, :conversation_id, :user_id,:to,:sdp,:candidate,:type)
  end
end
