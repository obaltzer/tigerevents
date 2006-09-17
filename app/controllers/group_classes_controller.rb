class GroupClassesController < ApplicationController
    before_filter :super_user
    
    def list
        @group_classes = GroupClass.find(:all)
        @complements = {}
        for c in @group_classes do
            @complements[c] = Array.new(@group_classes)
            @complements[c].delete_if { |x| x.id == c.id }
        end
        render_partial
    end

    def new
        @group_class = GroupClass.new
        render_partial
    end

    def create
        @group_class = GroupClass.new params[:group_class]
        if @group_class.save
            redirect_to params[:update_with]
        else
            render_partial 'embed_error_message'
        end
    end

    def remove
        old_class = GroupClass.find params[:id]
        begin
            new_class = GroupClass.find params[:new_class_id]
            if not old_class or not new_class
                @message = "You have to specify the replacement class."
                render_partial 'embed_error_message'
            elsif old_class != new_class
                for g in old_class.groups do
                    g.group_class = new_class
                    g.save
                end
                old_class.destroy
                # clear selectors cache
                SelectorsController.clearCache
                redirect_to params[:update_with]
            else
                @message = "The group class to delete and the replacement "\
                    + "class cannot be the same."
                render_partial 'embed_error_message'
            end
        rescue ActiveRecord::RecordNotFound
            @message = "Error has occurred."
            render_partial 'embed_error_message'
        end
    end
end
