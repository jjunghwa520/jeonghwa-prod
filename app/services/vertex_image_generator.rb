# frozen_string_literal: true

require "json"
require "base64"
require "fileutils"
require "net/http"
require "uri"
require "googleauth"

# VertexImageGenerator generates images using Google Vertex AI Imagen models
# and writes them into app/assets/images/generated so the asset pipeline can serve them.
class VertexImageGenerator
  DEFAULT_LOCATION = ENV.fetch("VERTEX_LOCATION", "asia-northeast3") # Seoul
  DEFAULT_MODEL_PATH = "imagegeneration"

  def initialize(project_id:, credentials_path:, location: DEFAULT_LOCATION)
    @project_id = project_id
    @credentials_path = credentials_path
    @location = location
  end

  def generate!(prompt:, filename:, width: 1600, height: 900, negative_prompt: nil, style_preset: nil)
    ensure_output_dir!

    token = fetch_access_token!
    # Use Imagen predict endpoint (2025 Q3 default)
    model = ENV.fetch("VERTEX_IMAGE_MODEL", "imagegeneration@006")
    endpoint = "https://#{@location}-aiplatform.googleapis.com/v1/projects/#{@project_id}/locations/#{@location}/publishers/google/models/#{model}:predict"

    body = {
      instances: [
        {
          prompt: prompt
        }
      ],
      parameters: {
        sampleCount: 1,
        negativePrompt: negative_prompt,
        imageDimensions: { width: width, height: height },
        style: (style_preset ? { preset: style_preset } : nil)
      }.compact
    }

    res = http_post_json(endpoint, body, token)

    unless res.is_a?(Net::HTTPSuccess)
      raise "Vertex AI image generation failed: #{res.code} #{res.body}"
    end

    json = JSON.parse(res.body)
    # Try common locations for base64 image bytes
    b64 = dig_base64(json)
    raise "No image returned from Vertex AI" unless b64

    bytes = Base64.decode64(b64)
    path = output_path_for(filename)
    File.binwrite(path, bytes)
    path
  end

  private

  def output_path_for(filename)
    File.join(Rails.root, "app/assets/images/generated", filename)
  end

  def ensure_output_dir!
    dir = File.join(Rails.root, "app/assets/images/generated")
    FileUtils.mkdir_p(dir)
  end

  def fetch_access_token!
    scope = ["https://www.googleapis.com/auth/cloud-platform"]
    creds = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(@credentials_path),
      scope: scope
    )
    creds.fetch_access_token!
    creds.access_token
  end

  def http_post_json(url, body, token)
    uri = URI.parse(url)
    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    req["Authorization"] = "Bearer #{token}"
    req.body = JSON.dump(body)

    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
  end

  # Attempts to find a base64 image field across possible response shapes
  def dig_base64(json)
    # v1beta1 imagegeneration: { predictions: [ { bytesBase64Encoded: "..." } ] }
    b64 = json.dig("predictions", 0, "bytesBase64Encoded")
    return b64 if b64

    # generative style: candidates[0].content.parts[0].inline_data.data
    json.dig("candidates", 0, "content", "parts", 0, "inline_data", "data")
  end
end


