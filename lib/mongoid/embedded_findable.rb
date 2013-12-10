module Mongoid

  # Helps to override find method in an embedded document.
  # Usage :
  #   - add to your model "include Mongoid::EmbeddedFindable"
  #   - override find method with:
  #     def find(id)
  #       find_by(Book, 'chapter', id)
  #     end
  module EmbeddedFindable

    extend ActiveSupport::Concern

    included do

      # Search an embedded document by id.
      #
      # Document is stored within embedding_class collection, and can be accessed through provided relation.
      # Also supports chained relation chips (if the searched document is nested in several embedded documents)
      #
      # Example, with a chapter embedded in a book, the book being embedded in a library.
      # use find_by(Library, "books", book_id) in Book class
      # and find_by(Library, "books.chapters", chapter_id) in Chapter class
      def self.find_by(embedding_class, relation, id = nil)
        return nil if id.nil? || id.blank?

        id = Moped::BSON::ObjectId.from_string(id) if id.is_a?(String)
        relation = relation.to_s unless relation.is_a?(String)

        relation_parts = relation.split('.')
        parent = embedding_class

        while relation_parts.length > 0
          result = parent.where("#{relation_parts.join('.')}._id" => id)
          item = result.is_a?(Criteria) ? result.first : result
          return nil if item.nil?
          parent = item.send(relation_parts.shift)
        end

        parent.is_a?(Criteria) ? parent.first : parent
      end

    end

  end

end