class CategoriesController < ApplicationController
    before_filter :login_required, :only => [:create_remote]
    def create_remote
        @category = Category.new(@params[:category])
	@category.created_by = @session[:user].id

        if @category.save
            # redirect back to the category listing for the current event
            redirect_to @params[:update_with]
        else
            render_partial 'embed_error_message'
        end
    end

    def new_remote
        render_partial
    end
end
