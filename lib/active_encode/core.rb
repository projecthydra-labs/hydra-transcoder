require 'active_support'
require 'active_encode/callbacks'

module ActiveEncode
  module Core
    extend ActiveSupport::Concern

    included do
      # Encode Identifier
      attr_accessor :id

      # Encode input
      # @return ActiveEncode::Input
      attr_accessor :input

      # Encode output(s)
      # @return Array[ActiveEncode::Output]
      attr_accessor :output

      # Encode options
      attr_accessor :options

      attr_accessor :current_operations
      attr_accessor :percent_complete

      # @deprecated
      attr_accessor :tech_metadata
    end

    module ClassMethods
      def default_options(_input)
        {}
      end

      def create(input, options = nil)
        object = new(input, options)
        object.create!
      end

      def find(id)
        raise ArgumentError, 'id cannot be nil' unless id
        encode = engine_adapter.find(id, cast: self)
        encode.run_callbacks(:find) { encode }
      end

      def list(*args)
        ActiveSupport::Deprecation.warn("#list will be removed without replacement in ActiveEncode 0.3")
        engine_adapter.list(args)
      end
    end

    def initialize(input, options = nil)
      @input = input
      @options = options || self.class.default_options(input)
    end

    def create!
      # TODO: Raise ArgumentError if self has an id?
      run_callbacks :create do
        merge!(self.class.engine_adapter.create(self))
      end
    end

    def cancel!
      run_callbacks :cancel do
        merge!(self.class.engine_adapter.cancel(self))
      end
    end

    def purge!
      ActiveSupport::Deprecation.warn("#purge! will be removed without replacement in ActiveEncode 0.3")
      run_callbacks :purge do
        self.class.engine_adapter.purge self
      end
    end

    def remove_output!(output_id)
      ActiveSupport::Deprecation.warn("#remove_output will be removed without replacement in ActiveEncode 0.3")
      self.class.engine_adapter.remove_output self, output_id
    end

    def reload
      run_callbacks :reload do
        merge!(self.class.engine_adapter.find(id, cast: self.class))
      end
    end

    def created?
      !id.nil?
    end

    # @deprecated
    def tech_metadata
      metadata = {}
      [:width, :height, :frame_rate, :duration, :file_size,
       :audio_codec, :video_codec, :audio_bitrate, :video_bitrate, :checksum].each do |key|
        metadata[key] = input.send(key)
      end
    end

    private

      def merge!(encode)
        @id = encode.id
        @input = encode.input
        @output = encode.output
        @state = encode.state
        @current_operations = encode.current_operations
        @errors = encode.errors
        @tech_metadata = encode.tech_metadata
        @created_at = encode.created_at
        @finished_at = encode.finished_at
        @updated_at = encode.updated_at
        @options = encode.options
        @percent_complete = encode.percent_complete

        self
      end
  end
end
