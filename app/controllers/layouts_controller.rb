class LayoutsController < ApplicationController
    # before_filter :super_user

    def edit
        render
    end

    def selector_selection
        @layout = Layout.find @params[:id]
        @active_selectors = @layout.selectors
        @available_selectors = Array.new(Selector.find_all)
        @available_selectors.reject! { |x|
            @active_selectors.include?(x)
        }
        render_partial
    end

    def active_selectors
        @layout = Layout.find @params[:id]
        @layout.selectors.clear
        if @params[:active_selectors]
            map = {}
            @params[:active_selectors].size.times { |i| 
                map[@params[:active_selectors][i].to_i] = i
            }
            for selector in Selector.find_all
                if map[selector.id]
                    @layout.selectors.push_with_attributes(
                        selector, "rank" =>  map[selector.id])
                end
            end
        end
        @order = "#{@params[:active_selectors].inspect} #{map.inspect}"
        render_partial
    end
end
