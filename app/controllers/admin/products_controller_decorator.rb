Admin::ProductsController.class_eval do
  def volume_prices
    load_object
  end

  update.failure.wants.html do
    if params[:product][:volume_prices_attributes].present?
      render :volume_prices
    else
      render :edit
    end
  end
end unless Admin::ProductsController.instance_methods.include? :volume_prices
