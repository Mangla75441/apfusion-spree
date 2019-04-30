module SpreeApfusion
  class Shipment

  
    def self.update shipment
      begin
        @shipment = shipment
        p @shipment.id
        p @shipment.number
        p @shipment.apfusion_shipment_id
        SpreeApfusion::Shipment.generate_shipment_hash 
        SpreeApfusion::OAuth.send(:PUT, '/api/v2/shipments/'+@shipment.apfusion_shipment_id.to_s+'.json', {shipment: @shipment_hash})
      rescue Exception => e
        
      end
      
    end
  

    def self.generate_shipment_hash 
      @shipment_hash = @shipment.attributes
      @shipment_hash["order_id"] = @shipment.order.apfusion_order_id
    end

  end
end