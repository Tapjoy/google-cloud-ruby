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


require "gcloud/gce"
require "gcloud/vision/connection"
require "gcloud/vision/credentials"
require "gcloud/vision/annotate"
require "gcloud/vision/image"
require "gcloud/vision/analysis"
require "gcloud/vision/errors"

module Gcloud
  module Vision
    ##
    # # Project
    #
    # Google Cloud Vision allows easy integration of vision detection features
    # within developer applications, including image labeling, face and landmark
    # detection, optical character recognition (OCR), and tagging of explicit
    # content.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   vision = gcloud.vision
    #   # ...
    #
    # See Gcloud#vision
    class Project
      ##
      # @private The Connection object.
      attr_accessor :connection

      ##
      # @private Creates a new Connection instance.
      def initialize project, credentials
        project = project.to_s # Always cast to a string
        fail ArgumentError, "project is missing" if project.empty?
        @connection = Connection.new project, credentials
      end

      # The Vision project connected to.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new "my-todo-project",
      #                       "/path/to/keyfile.json"
      #   vision = gcloud.vision
      #
      #   vision.project #=> "my-todo-project"
      #
      def project
        connection.project
      end

      ##
      # @private Default project.
      def self.default_project
        ENV["VISION_PROJECT"] ||
          ENV["GCLOUD_PROJECT"] ||
          ENV["GOOGLE_CLOUD_PROJECT"] ||
          Gcloud::GCE.project_id
      end

      def image source
        return source if source.is_a? Image
        Image.from_source source, self
      end

      def annotate *images, faces: 0, landmarks: 0, logos: 0, labels: 0,
                   text: false, safe_search: false, properties: false
        a = Annotate.new self
        a.annotate(*images, faces: faces, landmarks: landmarks, logos: logos,
                            labels: labels, text: text,
                            safe_search: safe_search, properties: properties)

        yield a if block_given?

        resp = connection.annotate a.requests
        fail ApiError.from_response(resp) unless resp.success?
        analyses = Array(resp.data["responses"]).map do |gapi|
          Analysis.from_gapi gapi
        end
        return analyses.first if analyses.count == 1
        analyses
      end
      alias_method :mark, :annotate
      alias_method :detect, :annotate

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end
    end
  end
end