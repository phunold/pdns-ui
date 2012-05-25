# make sure to include the needed pagination modules
require 'will_paginate'
require 'will_paginate/view_helpers/sinatra'

module WillPaginate
  module Sinatra
    module Helpers
      include ViewHelpers

      def will_paginate(collection, options = {})
        options[:renderer] ||= BootstrapLinkRenderer
        super(collection, options)
      end
    end

    class BootstrapLinkRenderer < LinkRenderer
      protected
      
      def html_container(html)
        tag :div, tag(:ul, html), container_attributes
      end

      def page_number(page)
        tag :li, link(page, page, :rel => rel_value(page)), :class => ('active' if page == current_page)
      end

      def previous_or_next_page(page, text, classname)
        tag :li, link(text, page || '#'), :class => [classname[0..3], classname, ('disabled' unless page)].join(' ')
      end

      def gap
         text = @template.will_paginate_translate(:page_gap) { '&hellip;' }
         %(<li class="disabled"><a href="#">#{text}</a></li>)
      end

    end
  end
end
