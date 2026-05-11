module ApplicationHelper
  include Pagy::Frontend

  def custom_pagy_nav(pagy)
    html = +%(<nav class="flex items-center justify-center space-x-2 mt-6 mb-4 text-sm font-medium">)
    
    if pagy.prev
      html << link_to("Prev", pagy_url_for(pagy, pagy.prev), class: "px-3 py-1.5 rounded-lg bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-gray-800 dark:text-gray-300 dark:hover:bg-gray-700 transition-colors")
    else
      html << %(<span class="px-3 py-1.5 rounded-lg bg-gray-50 text-gray-400 dark:bg-gray-900 dark:text-gray-600 opacity-50 cursor-not-allowed">Prev</span>)
    end

    pagy.series.each do |item|
      html << case item
              when Integer 
                link_to(item, pagy_url_for(pagy, item), class: "px-3 py-1.5 rounded-lg bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-gray-800 dark:text-gray-300 dark:hover:bg-gray-700 transition-colors")
              when String
                %(<span class="px-3 py-1.5 rounded-lg bg-blue-600 text-white shadow-md dark:bg-blue-500 cursor-default">#{item}</span>)
              when :gap    
                %(<span class="px-2 text-gray-500 dark:text-gray-400">...</span>)
              end
    end

    if pagy.next
      html << link_to("Next", pagy_url_for(pagy, pagy.next), class: "px-3 py-1.5 rounded-lg bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-gray-800 dark:text-gray-300 dark:hover:bg-gray-700 transition-colors")
    else
      html << %(<span class="px-3 py-1.5 rounded-lg bg-gray-50 text-gray-400 dark:bg-gray-900 dark:text-gray-600 opacity-50 cursor-not-allowed">Next</span>)
    end

    html << %(</nav>)
    html.html_safe
  end
end