module ApplicationHelper
  include Pagy::Frontend
  def flash_class_for(type)
    base_classes = "px-4 py-2 rounded-lg shadow-md"
    case type.to_sym
    when :success
      "bg-green-500 text-white #{base_classes}"
    when :danger
      "bg-red-500 text-white #{base_classes}"
    when :alert
      "bg-yellow-500 text-white #{base_classes}"
    when :notice
      "bg-blue-500 text-white #{base_classes}"
    else
      "bg-gray-500 text-white #{base_classes}"
    end
  end
end