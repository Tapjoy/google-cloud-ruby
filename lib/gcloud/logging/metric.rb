# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


module Gcloud
  module Logging
    ##
    # # Metric
    #
    # A logs-based metric. The value of the metric is the number of log entries
    # that match a logs filter.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   logging = gcloud.logging
    #   metric = logging.metric "severe_errors"
    #
    class Metric
      ##
      # @private The Connection object.
      attr_accessor :connection

      ##
      # @private The Google API Client object.
      attr_accessor :gapi

      ##
      # @private Create an empty File object.
      def initialize
        @connection = nil
        @gapi = {}
      end

      ##
      # The client-assigned metric identifier. Metric identifiers are limited to
      # 1000 characters and can include only the following characters: `A-Z`,
      # `a-z`, `0-9`, and the special characters `_-.,+!*',()%/\`. The
      # forward-slash character (`/`) denotes a hierarchy of name pieces, and it
      # cannot be the first character of the name.
      def name
        @gapi["name"]
      end

      ##
      # The description of this metric, which is used in documentation.
      def description
        @gapi["description"]
      end

      ##
      # An [advanced logs
      # filter](https://cloud.google.com/logging/docs/view/advanced_filters).
      def filter
        @gapi["filter"]
      end

      ##
      # @private New Metric from a Google API Client object.
      def self.from_gapi gapi, conn
        new.tap do |f|
          f.gapi = gapi
          f.connection = conn
        end
      end

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end
    end
  end
end
