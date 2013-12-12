class MigrateClientsToMarkdown < Mongoid::Migration
  def self.up
    Client.where(_type: 'Html::Client').each(&:to_markdown!)
  end

  def self.down
  end
end