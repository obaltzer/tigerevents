class ManagerController < ApplicationController
 
   before_filter :login_required

   def index
      @groups_unapproved = Group.find_all_by_approved( 0 )
      @group_classes = GroupClass.find_all
      @group_classes_approveable = GroupClass.find_all_by_id( 1 )
   end

end
