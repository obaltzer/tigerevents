class PrioritiesController < ApplicationController
    before_filter :super_user

    def list
        @priorities = Priority.find :all, :order => "rank"
        @complements = {}
        for p in @priorities do
            @complements[p] = \
                Array.new(@priorities).delete_if {|x| x.id == p.id }
        end
        render_partial
    end

    def new
        @priority = Priority.new
        render_partial
    end

    def create
        p = Priority.find(:first, :order => "rank DESC")
        if not p
            @params[:priority][:rank] = 1
        else
            @params[:priority][:rank] = p.rank + 1
        end
        @priority = Priority.new @params[:priority]
        if @priority.save
            redirect_to @params[:update_with]
        else
            render_partial 'embed_error_message'
        end
    end

    def remove
        @old_p = Priority.find @params[:id]
        begin
            new_p = Priority.find @params[:new_priority_id]
            if not @old_p or not new_p
                @message = "You have to specify the replacement priority."
                render_partial 'embed_error_message'
            elsif @old_p != new_p
                Event.update_all "priority_id = #{new_p.id}", \
                                 "priority_id = #{@old_p.id}"
                # XXX this does not update selectors see #110
                @old_p.destroy
                # clear the caches for the events beeing rendered with the
                # new priority
                SelectorsController.clearCache
                render_partial
            else
                @message = "You cannot replace a priority with itself."
                render_partial 'embed_error_message'
            end
        rescue ActiveRecord::RecordNotFound
            @message = "Error! Your computer is going to explode!"
            render_partial 'embed_error_message'
        end
    end
    
    def order
        if @params[:priorities]
            map = {}
            @params[:priorities].size.times { |i| 
                map[@params[:priorities][i].to_i] = i + 1
            }
            for p in Priority.find_all
                if map[p.id]
                    p.update_attribute :rank, map[p.id]
                end
            end
        end
        render_partial
    end
end         
