class CategoriesController < ApplicationController
    before_filter :login_required, :only => [:create_remote]

    def list
      @categories = Category.find (:all, :order => "name")
      @tagged_items = Event.tags_count(:limit => 100)
    end

    def show
      @category = Category.find(@params[:id])
      @events = Event.find_tagged_with(:any => @category.name, :conditions => \
        ["startTime > ?", Time.now])
    end
                                        
    # create a new category from a JavaScript request
    def create
        @category = Category.new(@params[:category])
        @category.created_by = @session[:user].id

        if @category.save
            # redirect back to the category listing for the current event
            redirect_to @params[:update_with]
        else
            render_partial 'embed_error_message'
        end
    end

    def delete
        if (@params[:category] != "")
            @old_c = Category.find @params[:category]
            Category.delete(@params[:category])
        end
        render_partial
    end

    def list_categories
        @categories = Category.find :all, :order => "name"
        render_partial
    end

    # list existing categories
    def list_admin
        @categories = Category.find :all, :order => "name"
        @complements = {}
        for c in @categories do
            @complements[c] = \
                Array.new(@categories).delete_if {|x| x.id == c.id }
        end
        render_partial
    end

    def remove
        @old_c = Category.find @params[:id]
        begin
            new_c = Category.find @params[:new_category_id]
            if not @old_c or not new_c
                @message = "You have to specify the replacement category."
                render_partial 'embed_error_message'
            elsif @old_c != new_c
                # for all events that are associated with the old category
                for e in @old_c.events do
                    # delete the category from the event
                    e.categories.delete(@old_c)
                    if not e.categories.include?(new_c)
                        # add the new category to the event if it is not 
                        # yet associated with it
                        e.categories << new_c
                    end
                end
                @old_c.destroy
                SelectorsController.clearCache
                render_partial
            else
                @message = "You cannot replace a category with itself."
                render_partial 'embed_error_message'
            end
        rescue ActiveRecord::RecordNotFound
            @message = "Error! Your computer is going to explode!"
            render_partial 'embed_error_message'
        end
    end
end
