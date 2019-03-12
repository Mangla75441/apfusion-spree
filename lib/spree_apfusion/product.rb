module SpreeApfusion
  class Product

  	def self.create product
      @product = product
      @product_hash 
      SpreeApfusion::Product.generate_product_hash 
  		SpreeApfusion::OAuth.send(:post, '/api/v2/products.json', {product: @product_hash})
  	end


    def self.update product
      @product = product
      @product.id
      SpreeApfusion::Product.generate_product_hash 
      SpreeApfusion::OAuth.send(:PUT, '/api/v2/products/'+@product.id.to_s+'.json', {product: @product_hash}) 
    end  

    def self.destroy product
      @product = product
      @product.id
      SpreeApfusion::Product.generate_product_hash 
      SpreeApfusion::OAuth.send(:DELETE, '/api/v2/products/'+@product.id.to_s+'.json', {product: @product_hash}) 
    end  

    def self.generate_product_hash 
      @product_hash = @product.attributes
      SpreeApfusion::Product.add_product_price
      SpreeApfusion::Product.add_option_type_id
      SpreeApfusion::Product.add_sku


    end


    def self.add_product_price 
      if @product.resale_amount.present?
        @product_hash["price"] = @product.resale_amount
      else
        @product_hash["price"] = @product.price  
      end
      @product_hash["resale_amount"] = @product.resale_amount
      @product_hash["bsap_amount"] = @product.bsap_amount

    end

    def self.add_option_type_id
      @product_hash["option_type_ids"] = @product.option_types.collect(&:id)

      @product.option_types.collect(&:id)
    end

    def self.add_sku
      @product_hash["sku"] = @product.sku
    end

	end
end