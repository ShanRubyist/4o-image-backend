require 'bot'

class Api::V1::AiController < UsageController
  skip_before_action :check_credits, only: [:ai_call_info]



  def current_user
    User.first
  end


  def food_photography_generator
    prompt = params['prompt'] || 'GHBLI anime style photo'
    raise 'prompt can not be empty' unless prompt.present?

    model_name = 'black-forest-labs/flux-schnell'

    conversation = current_user.conversations.create
    ai_call = conversation.ai_calls.create(
      task_id: SecureRandom.uuid,
      prompt: prompt,
      status: 'submit',
      input: params,
      "cost_credits": current_cost_credits)

    ai_bot = Bot::Replicate.new
    prompt = '你是一个图片生成 prompt 大师，根据用户给出的内容，生成 single line drawing.' + prompt
    task = ai_bot.generate_image(prompt,model_name: model_name)

    # query task status
    images = ai_bot.query_image_task(task) do |h|
      ai_call.update_ai_call_status(h)
    end

    # OSS
    require 'open-uri'
    SaveToOssJob.perform_now(ai_call.id,
                             :generated_media,
                             {
                               io: images.first,
                               filename: URI(images.first).path.split('/').last,
                               content_type: "image/jpeg"
                             }
    )

    render json: {
      images: images
    }
  end
  def logo_generator
    prompt = params['prompt'] || 'GHBLI anime style photo'
    raise 'prompt can not be empty' unless prompt.present?

    model_name = 'black-forest-labs/flux-schnell'

    conversation = current_user.conversations.create
    ai_call = conversation.ai_calls.create(
      task_id: SecureRandom.uuid,
      prompt: prompt,
      status: 'submit',
      input: params,
      "cost_credits": current_cost_credits)

    ai_bot = Bot::Replicate.new
    prompt = '你是一个图片生成 prompt 大师，根据用户给出的内容，生成 single line drawing.' + prompt
    task = ai_bot.generate_image(prompt,model_name: model_name)

    # query task status
    images = ai_bot.query_image_task(task) do |h|
      ai_call.update_ai_call_status(h)
    end

    # OSS
    require 'open-uri'
    SaveToOssJob.perform_now(ai_call.id,
                             :generated_media,
                             {
                               io: images.first,
                               filename: URI(images.first).path.split('/').last,
                               content_type: "image/jpeg"
                             }
    )

    render json: {
      images: images
    }
  end
  def medal_generator
    prompt = params['prompt'] || 'GHBLI anime style photo'
    raise 'prompt can not be empty' unless prompt.present?

    model_name = 'black-forest-labs/flux-schnell'

    conversation = current_user.conversations.create
    ai_call = conversation.ai_calls.create(
      task_id: SecureRandom.uuid,
      prompt: prompt,
      status: 'submit',
      input: params,
      "cost_credits": current_cost_credits)

    ai_bot = Bot::Replicate.new
    prompt = '你是一个图片生成 prompt 大师，根据用户给出的内容，生成 single line drawing.' + prompt
    task = ai_bot.generate_image(prompt,model_name: model_name)

    # query task status
    images = ai_bot.query_image_task(task) do |h|
      ai_call.update_ai_call_status(h)
    end

    # OSS
    require 'open-uri'
    SaveToOssJob.perform_now(ai_call.id,
                             :generated_media,
                             {
                               io: images.first,
                               filename: URI(images.first).path.split('/').last,
                               content_type: "image/jpeg"
                             }
    )

    render json: {
      images: images
    }
  end

  # 你是一个图片生成 prompt 大师，根据用户给出的内容，生成奖牌的英文 prompt, 奖牌形状是星型，材质是金子。
  # 你是一个图片生成 prompt 大师，根据用户给出的内容，生成 branding logo
  # 你是一个图片生成 prompt 大师，根据用户给出的内容，生成 Food Photography
  def single_line_drawing
    ai=AiCall.order("created_at desc").first
    render json: {
      images: ai.data['image']
    }
  end
  def single_line_drawing2
    prompt = params['prompt'] || 'GHBLI anime style photo'
    raise 'prompt can not be empty' unless prompt.present?

    model_name = 'black-forest-labs/flux-schnell'

    conversation = current_user.conversations.create
    ai_call = conversation.ai_calls.create(
      task_id: SecureRandom.uuid,
      prompt: prompt,
      status: 'submit',
      input: params,
      "cost_credits": current_cost_credits)

    ai_bot = Bot::Replicate.new
    prompt = '你是一个图片生成 prompt 大师，根据用户给出的内容，生成 single line drawing.' + prompt
    task = ai_bot.generate_image(prompt,model_name: model_name)

    # query task status
    images = ai_bot.query_image_task(task) do |h|
      ai_call.update_ai_call_status(h)
    end

    # OSS
    require 'open-uri'
    SaveToOssJob.perform_now(ai_call.id,
                             :generated_media,
                             {
                               io: images.first,
                               filename: URI(images.first).path.split('/').last,
                               content_type: "image/jpeg"
                             }
    )

    render json: {
      images: images
    }
  end
  def four_panel_comic
    prompt = params['prompt']
    raise 'prompt can not be empty' unless prompt.present?

    conversation = current_user.conversations.create
    ai_call = conversation.ai_calls.create(
      task_id: SecureRandom.uuid,
      prompt: prompt,
      status: 'submit',
      input: params,
      "cost_credits": current_cost_credits)

    ai_bot = Bot::Gpt4oimage.new
    task = ai_bot.generate_image(prompt)
    puts task
    # query task status
    images = ai_bot.query_image_task(task) do |h|
      puts '*'*100
      puts h
      ai_call.update_ai_call_status(h)
    end

    # OSS
    require 'open-uri'
    SaveToOssJob.perform_now(ai_call.id,
                             :generated_media,
                             {
                               io: images.first,
                               filename: URI(images.first).path.split('/').last,
                               content_type: "image/jpeg"
                             }
    )

    render json: {
      images: images
    }
  end

  def ghibli
    type = params['type']
    raise 'type can not be empty' unless type.present?

    prompt = params['prompt'] || 'GHBLI anime style photo'
    raise 'prompt can not be empty' unless prompt.present?

    image = params['image']
    raise 'image can not be empty' unless image.present?

    model_name = 'aaronaftab/mirage-ghibli'

    conversation = current_user.conversations.create
    ai_call = conversation.ai_calls.create(
      task_id: SecureRandom.uuid,
      prompt: prompt,
      status: 'submit',
      input: params,
      "cost_credits": current_cost_credits)

    if type.to_i == 0
      # OSS
      SaveToOssJob.perform_now(ai_call.id,
                               :input_media,
                               {
                                 io: image.tempfile,
                                 filename: image.original_filename + Time.now.to_s,
                                 content_type: image.content_type
                               }
      )
      image = url_for(ai_call.input_media.last)
    end

    ai_bot = Bot::Replicate.new
    task = ai_bot.generate_image(prompt, image: image, model_name: model_name)

    # query task status
    images = ai_bot.query_image_task(task) do |h|
      ai_call.update_ai_call_status(h)
    end

    # OSS
    require 'open-uri'
    SaveToOssJob.perform_later(ai_call.id,
                               :generated_media,
                               {
                                 io: images.first,
                                 filename: URI(image).path.split('/').last,
                                 content_type: "image/jpeg"
                               }
    )

    render json: {
      images: images
    }
  end

  def gen_image
    type = params['type']
    raise 'type can not be empty' unless type.present?

    prompt = params['prompt'] || 'GHBLI anime style photo'
    raise 'prompt can not be empty' unless prompt.present?

    image = params['image']
    raise 'image can not be empty' unless image.present?

    model_name = 'aaronaftab/mirage-ghibli'

    conversation = current_user.conversations.create
    ai_call = conversation.ai_calls.create(
      task_id: SecureRandom.uuid,
      prompt: prompt,
      status: 'submit',
      input: params,
      "cost_credits": current_cost_credits)

    if type.to_i == 0
      # OSS
      SaveToOssJob.perform_now(ai_call.id,
                               :input_media,
                               {
                                 io: image.tempfile,
                                 filename: image.original_filename + Time.now.to_s,
                                 content_type: image.content_type
                               }
      )
      image = url_for(ai_call.input_media.last)
    end

    ai_bot = Bot::Replicate.new
    task = ai_bot.generate_image(prompt, image: image, model_name: model_name)

    # query task status
    images = ai_bot.query_image_task(task) do |h|
      ai_call.update_ai_call_status(h)
    end

    # OSS
    require 'open-uri'
    SaveToOssJob.perform_later(ai_call.id,
                               :generated_media,
                               {
                                 io: images.first,
                                 filename: URI(image).path.split('/').last,
                                 content_type: "image/jpeg"
                               }
    )

    render json: {
      images: images
    }
  end

  def gen_video
    conversation = current_user.conversations.create

    # generate video task
    ai_bot = Bot::Fal.new
    task_id = ai_bot.generate_video(prompt,
                                    image_url: params[:image_url],
                                    path: params[:path])

    ai_call = conversation.ai_calls.create(
      task_id: task_id,
      prompt: params[:prompt],
      status: 'submit',
      input: params,
      "cost_credits": current_cost_credits)

    # query video task status
    video = ai_bot.query_video_task(task_id) do |h|
      ai_call.update_ai_call_status(h)
    end

    # OSS
    require 'open-uri'
    SaveToOssJob.perform_later(ai_call.id,
                               :generated_media,
                               {
                                 io: URI.open(video),
                                 filename: URI(video).path.split('/').last,
                                 content_type: "video/mp4"
                               }
    )

    render json: {
      videos: [video]
    }
  end

  def ai_call_info
    params[:page] ||= 1
    params[:per] ||= 20

    ai_calls = AiCall.joins(conversation: :user).where(users: { id: current_user.id })
                     .order("created_at desc")
                     .page(params[:page].to_i)
                     .per(params[:per].to_i)

    result = ai_calls.map do |item|
      {
        # input_media: (
        #   item.input_media.map do |media|
        #     url_for(media)
        #   end
        # ),
        generated_media: (
          item.generated_media.map do |media|
            url_for(media)
          end
        ),
        prompt: item.prompt,
        status: item.status,
        input: item.input,
        data: item.data,
        created_at: item.created_at,
        cost_credits: item.cost_credits,
        system_prompt: item.system_prompt,
        business_type: item.business_type
      }
    end

    render json: {
      total: ai_calls.total_count,
      histories: result
    }
  end

end