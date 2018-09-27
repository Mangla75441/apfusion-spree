module SpreeApfusion
  class Image

    def self.create image
      p "========Create image called=========="
      p @image = image
      p @image.viewable.product.id
      @image_hash 
      SpreeApfusion::Image.generate_image_hash 
      SpreeApfusion::OAuth.send(:post, '/api/v2/products/'+@image.viewable.product.id.to_s+'/images.json', {image: @image_hash})
    end

    def self.update image
      @image = image

      p "========UPDate call Values====="
      p @image.id
      SpreeApfusion::Image.generate_image_hash 
      SpreeApfusion::OAuth.send(:PUT, '/api/v2/products/'+@image.viewable.product.id.to_s+'/images/'+@image.id.to_s+'.json', {image: @image_hash})
    end


    def self.destroy image
      @image = image
      p "========Delete call====="
      p @image.id
      SpreeApfusion::Image.generate_image_hash 
      SpreeApfusion::OAuth.send(:DELETE ,'/api/v2/products/'+@image.viewable.product.id.to_s+'/images/'+@image.id.to_s+'.json', {image: @image_hash})
    end
    


    def self.add_image_attachment

      p "add image URL CALLED======================"*2
      p @image.attachment.url
      p "-------------------------"
      p path = @image.attachment.url[/[^?]+/]
      p "++++++++++++++++++++++++++++++++++"
      p url = "#{Rails.root}/public#{path}"
      @image_hash["url"] = url
      
    end

    def self.check_variant_is_master 
      is_master = @image.viewable.is_master 
      if is_master == true
        @image_hash["is_master"] = is_master
      end  
    end


    def self.generate_image_hash 
      @image_hash = @image.attributes
      SpreeApfusion::Image.add_image_attachment
      SpreeApfusion::Image.check_variant_is_master
    end

  end
end