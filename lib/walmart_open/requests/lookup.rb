require "walmart_open/request"
require "walmart_open/item"
require "walmart_open/errors"

module WalmartOpen
  module Requests
    class Lookup < Request
      def initialize(item_id, params = {})
        @is_array = item_id.class == Array
        if @is_array
          self.path = "items"
          ids = ''
          item_id.each_index { |i| ids += (i == 0) ? item_id[i] : ",#{item_id[i]}" }
          params[:ids] = ids
        else
          self.path = "items/#{item_id}"
        end

        self.params = params
      end

      private

      def parse_response(response)
        if @is_array
          items = []
          response.parsed_response['items'].each do |item|
            items << Item.new(item)
          end
          items
        else
          Item.new(response.parsed_response)
        end
      end

      def verify_response(response)
        if response.code == 400
          raise WalmartOpen::ItemNotFoundError, response.parsed_response.inspect
        end
        super
      end
    end
  end
end
