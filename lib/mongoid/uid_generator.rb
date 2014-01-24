module Mongoid

  class UidGenerator

    def self.get_uid_for(model, length = UID_SIZE, field_name = "uid")
      uid = generate_uid(length)
      while (model.send("where", {field_name => uid}).exists?)
        uid = generate_uid(length)
      end
      uid
    end

    def self.generate_uid(length = UID_SIZE)
      uid = rand(36**length).to_s(36)
      #ugly trick to be sure that uid length is UID_SIZE
      while (uid.length != length) do
        uid += uid[-1].chr
      end
      uid
    end
  end

end
