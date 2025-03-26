module Api
  module V1
    class ToolsController < ApplicationController
      # GET /api/v1/tools/published
      def published
        @tools = Tool.published
        render json: (@tools.map do |tool|
          tool_data = tool.scraped_infos.first.data
          {
            id: tool.id,
            name: tool.name,
            url: tool.url,
            logo: tool_data['logo'],
            description: tool_data['description'],
            tags: tool.tags.map(&:name),
            # likes: 13500,
            # growth: 27.52,
            # featured: false
          }
        end)
      end

      # GET /api/v1/tools/unpublished
      def unpublished
        @tools = Tool.unpublished
        render json: @tools
      end
      
      # POST /api/v1/tools/1/publish
      def publish
        @tool = Tool.find(params[:id])
        @tool.update(published: true)
        render json: @tool
      end
      
      # POST /api/v1/tools/1/unpublish
      def unpublish
        @tool = Tool.find(params[:id])
        @tool.update(published: false)
        render json: @tool
      end
      
      # GET /api/v1/tools/search
      def search
        @tools = Tool.published.search(params[:query])
        render json: @tools
      end
      
      private
      
      def resource_class
        Tool
      end
      
      def permitted_params
        [:name, :description, :url, :logo_url, :published, :popularity, :pricing_type, tag_ids: []]
      end
    end
  end
end 