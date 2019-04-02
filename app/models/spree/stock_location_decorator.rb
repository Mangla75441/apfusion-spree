Spree::StockLocation.class_eval do
		# after_create :create_at_apfusion
		# after_update :update_at_apfusion
		# after_destroy :destroy_at_apfusion


		def create_at_apfusion
			SpreeApfusion::StockLocation.create(self)
		end

		def update_at_apfusion
			SpreeApfusion::StockLocation.update(self)
		end

		def destroy_at_apfusion
			SpreeApfusion::StockLocation.destroy(self)
		end

		def self.create_all_stock_locations
			Spree::StockLocation.all.each do |stock_location|
				SpreeApfusion::StockLocation.create(stock_location)
			end 
		end

	end