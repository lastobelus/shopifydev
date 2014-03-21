class ProductCachesController < ApplicationController
  around_filter :shopify_session

  # GET /product_caches
  # GET /product_caches.json
  def index
    @jid = ProductCacheUpdater.perform_async(current_shop.id)
    params[:page] = 1 if params[:page] == ""
    current_shop.product_caches.page params[:page]
  end

  # PATCH/PUT /product_caches/update_multiple
  def update_multiple
    
    @product_caches = current_shop.product_caches.update(
      params[:product_caches].keys, 
      permitted_params(params[:product_caches].values)
    ).reject { |p| p.errors.empty? }
    if @product_caches.empty? 
      flash[:success] = "Products updated"
      redirect_to product_caches_page_path(page: params[:page])
    else
      flash.now[:error] = "The following entries had errors:"
      @product_caches = []
      render :index
    end
  end
  
  # GET
  def status
    data = Sidekiq::Status::get_all(params[:jid])
    data[:created_ids] = data[:created_ids].split(',')
    data[:updated_ids] = data[:updated_ids].split(',')
    data[:status] = case data[:status]
    when 'queued', 'working'
      'updating cache...'
    else
      'product cache updated'
    end
    render json: data.to_json
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def product_caches_params(arr)
   arr.map{|h| h.permit(:custom, :fields)}
  end
end
