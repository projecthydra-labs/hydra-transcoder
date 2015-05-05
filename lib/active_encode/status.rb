require 'active_support'

module ActiveEncode
  module Status
    extend ActiveSupport::Concern

    included do
      # Current state of the encoding process
      attr_accessor :state

      attr_accessor :current_operations

      attr_accessor :errors
    end

    def created?
      !id.nil?
    end

    def cancelled?
      state == :cancelled
    end

    def completed?
      state == :completed
    end

    def running?
      state == :running
    end

    def failed?
      state == :failed
    end
  end
end
