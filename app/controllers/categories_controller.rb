class CategoriesController < ApplicationController
    before_filter :login_required, :only => [:create_remote]
    before_filter :super_user, :only =>[:edit]

    def list
        if(params['page']==nil)
            params['page']=1
        end
        @categories = Category.find(:all, 
          :order => "name", 
          :include => "events", 
          :conditions => ["events.startTime > ?", Time.now])
        @categories_pages = Paginator.new self, @categories.size, 10, params['page']
        @tagged_items = Event.tags_count(:limit => 100, 
          :conditions => ["startTime > ?", Time.now])
    end

    def show
      # this makes sure we can find tags by ID and name
      if params[:id]
        @category = Category.find(params[:id])
      elsif params[:name]
        @category = Category.find(:first, 
          :conditions => ["name = ?", params[:name]])
      end
      events = Event.find_tagged_with(:any => @category.name,
        :separator => ",",
        :order => "startTime ASC")
      @events_past, @events_future = events.partition &:expired?
    end
                                        
    def delete
        if (params[:category] != "")
            @old_c = Category.find params[:category]
            Category.delete(params[:category])
        end
        render_partial
    end

    def split
        if (params[:category_split] !="")
            @old_c = Category.find(params[:category_split])
            @events = Event.find_tagged_with(:any => @old_c.name)
            Category.delete(params[:category_split])
            for event in @events do
                event.tag(params[:tags], :separator => ',', :attributes =>\
                    {:created_by => session[:user]})
            end
        end
        render_partial
    end

    def tag_cloud
        list
    end
    
    # list existing categories
    def edit
        @categories = Category.find(:all, :order => "name")
        @complements = {}
        for c in @categories do
            @complements[c] = \
                Array.new(@categories).delete_if {|x| x.id == c.id }
        end
    end

    def remove
        @old_c = Category.find params[:id]
        begin
            new_c = Category.find params[:new_category_id]
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
