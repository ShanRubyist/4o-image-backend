require 'faraday'
require 'bot'

module Bot
  class Gpt4oimage < AIModel
    def initialize(api_key = ENV.fetch('TUZI_API_KEY'), api_base_url = 'https://api.tu-zi.com')
      @api_key = api_key
      @api_base_url = api_base_url
    end

    def image_api(content, options = {})
      path = options.fetch(:path, '/v1/images/generations')
      image = options.fetch(:image, nil)


      prompt = options.fetch(:prompt, nil)

      resp = client.post(path) do |req|
        req.headers['Content-Type'] = 'application/json'
        req.headers['Authorization'] = "Bearer #{@api_key}"
        req.body = {
          filesUrl: [image],
        prompt:prompt,
          n:1,
          "size": "1024x1024",
          "model": "gpt-4o-image-vip",
        }.to_json
      end

      # if response.success?
      # yield data
      # else
      # @error_message = 'Failed to get data'
      # end

      h = JSON.load(resp.body)
      puts h
      if h['data'] && h['data']['taskId']
        return h['data']['taskId']
      else
        fail h.to_json
      end
    end

    def image_api2(content, options = {})
      # return '96177fbf1cf4da619c984a9ba50fcdc7'
      return 'e78747c360de640e4193edb607c3841b'
    end

    private

    def query_image_task_api(task_id)

      path = "/api/v1/gpt4o-image/record-info?taskId=#{task_id}"

      resp = client.get(path) do |req|
        req.headers['Content-Type'] = 'application/json'
        req.headers['Authorization'] = "Bearer #{@api_key}"
      end
      puts "query status: "
      puts resp.body
      if resp.success?

        h = JSON.parse(resp.body)
        if h['data']['status'] == 'SUCCESS'
          return {
            status: 'success',
            image: h['data']['response']['resultUrls'],
            data: h
          }
        elsif h['data']['status'] == 'GENERATE_FAILED' || h['data']['status'] == 'CREATE_TASK_FAILED'
          fail 'generate image failed'
        else
          return {
            status: h['data']['status'],
            image: nil,
            data: h
          }
        end
      else
        fail 'query image status error'
      end
    end

    def client
      @client ||= Faraday.new(url: @api_base_url)
    end

    def text_resp(data)
      rst = []

      h = JSON.parse(data)

      h.each do |msg|
        @buff = ''
        return unless msg
        candidate = msg['candidates']&.first
        return unless candidate

        content = candidate['content']
        part = content['parts']&.first rescue nil

        rst << {
          "choices": [
            {
              "index": 0,
              "delta": {
                "role": content['role'],
                "content": part['text'] ? part['text'] : ''
              },
              "finish_reason": candidate['finishReason']
            }
          ]
        }
      end
      rst
    end
  end
end


