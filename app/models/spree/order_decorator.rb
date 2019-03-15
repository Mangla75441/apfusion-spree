Spree::Order.class_eval do
	def self.sync_orders
		p "sync ordre clladed"*5
		response = SpreeApfusion::Order.get_orders
		response[:response].each do |order|
			p "response called"*8
			p order
			p "===="*20
		 	p order_ids = Spree::Order.all.collect(&:apfusion_order_id)
		 	unless order_ids.include?(order['id'])
		 		p "unless called"
		 		# begin
		 			p "begin called"
		 			@order = Spree::Order.new
				 	order["bill_address_attributes"].delete('id')
				 	order["ship_address_attributes"].delete('id')
				 	order["bill_address_attributes"].delete('email')
				 	order["ship_address_attributes"].delete('email')
				 	order["ship_address_attributes"].delete('customer_number')
				 	order["bill_address_attributes"].delete('customer_number')
				 	bill_address = order["bill_address_attributes"]
				 	ship_address = order["ship_address_attributes"]
				 	orders_attributes = {'bill_address_attributes'=>bill_address,'ship_address_attributes'=>ship_address,'email'=>order['email'],'apfusion_order_id'=>order['id']}

					order["line_items"].each do |line_item|
						if line_item["product_id"].present?
							variant = Spree::Product.find(line_item["product_id"]).master
						else			
							variant = Spree::Variant.find(line_item["source_id"]).master
						end
						begin
						 quantity = line_item["quantity"]
							@order.contents.add(variant,quantity, {},variant.bsap_amount)
						rescue ActiveRecord::ReproductscordInvalid => e
							error = e.record.errors.full_messages.join(', ')
						end
					end
					orders_attributes
					@order.update_attributes(orders_attributes)
					@order.next
					@order.next

					order["line_items"].each do |line_item|
						p "line_item"*20
						p line_item
						p "===="*20
						p shipping_method_name = line_item["shipping_method"]["linked_from"]
						p line_item["shipping"]
						p shipping_method_name.present?
						if shipping_method_name.present?
							p @shipping_method_id =  Spree::ShippingMethod.find_by_name(shipping_method_name)
							@order.shipments.each do |shipment| 
								shipment.update_attributes(apfusion_shipment_id: line_item["shipping"]["number"] )
								shipment.shipping_rates.update_all(selected: false)
								shipment.shipping_rates.find_by_shipping_method_id(@shipping_method_id).update_attributes(selected: true)
							end	
							@order.update_totals
			        @order.persist_totals
			      else
			      	p "else callde"*20
			      	@order.shipments.last.update_attributes(apfusion_shipment_id: line_item["shipping"]["number"] )
				    end  
					end	

					check_payment_method = Spree::PaymentMethod.where(name: "Create at Apfusion").last
					if check_payment_method.present?
						payment_method = 	check_payment_method
					else
						payment_method =  Spree::PaymentMethod.create({"type"=>"Spree::PaymentMethod::Check", "display_on"=>"both", "auto_capture"=>"", "active"=>"true", "name"=>"Create at Apfusion", "description"=>"Payment for Apfusion app"})
					end
					@order.payments.create(amount: @order.total, payment_method_id: payment_method.id)
					@order.next
					@order.next
					

		 		# rescue Exception => e
		 		# 	p e.message
		 		# end
		 	end	
		end 	
	end

	def deliver_order_confirmation_email
		p "deliver order confirmation called"*20
		unless self.apfusion_order_id.present?
	  	Spree::OrderMailer.confirm_email(id).deliver_later
	  	update_column(:confirmation_delivered, true)
	  end	
	end

end



