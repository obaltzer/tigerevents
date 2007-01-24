class PrioritiesController < ApplicationController
    before_filter :super_user

    def list
        @priorities = Priority.find :all, :order => "rank"
        @complements = {}
        for p in @priorities do
            @complements[p] = \
                Array.new(@priorities).delete_if {|x| x.id == p.id }
        end
    end

    def new
        @priority = Priority.new
        render_partial
    end

    def create
        priority = Priority.find(:first, :order => "rank DESC")
        if not priority
            params[:priority][:rank] = 1
        else
            params[:priority][:rank] = priority.rank + 1
        end
        @priority = Priority.new(params[:priority])
        if @priority.save
            redirect_to params[:update_with]
        else
            render :partial => 'embed_error_message'
        end
    end

    def remove
        @old_priority = Priority.find(params[:id])
        begin
            new_priority = Priority.find(params[:new_priority_id])
            if not @old_priority or not new_priority
                @message = "You have to specify the replacement priority."
                render :partial => 'embed_error_message'
            elsif @old_priority != new_priority
                Event.update_all "priority_id = #{new_priority.id}", \
                                 "priority_id = #{@old_priority.id}"
                # XXX this does not update selectors see #110
                @old_priority.destroy
                # clear the caches for the events beeing rendered with the
                # new priority
                SelectorsController.clearCache
                render_partial
            else
                @message = "You cannot replace a priority with itself."
                render :partial => 'embed_error_message'
            end
        rescue ActiveRecord::RecordNotFound
            @message = "Error! Your computer is going to explode!"
            render :partial => 'embed_error_message'
        end
    end
    
    def order
        if params[:priorities]
            map = {}
            params[:priorities].size.times { |i| 
                map[params[:priorities][i].to_i] = i + 1
            }
            for priority in Priority.find(:all)
                if map[priority.id]
                    priority.update_attribute :rank, map[priority.id]
                end
            end
        end
        render_partial
    end
end         
