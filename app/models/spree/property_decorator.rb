Spree::Property.class_eval do
		# after_create :create_at_apfusion
		# after_update :update_at_apfusion
		# after_destroy :destroy_at_apfusion


		def create_at_apfusion
			SpreeApfusion::Property.create(self)
		end

			
		def self.create_all_property
			Spree::Property.all.each do |property|
				SpreeApfusion::Property.create(property)
			end 
		end


		def update_at_apfusion
			SpreeApfusion::Property.update(self)
		end

		def destroy_at_apfusion
			SpreeApfusion::Property.destroy(self)
		end

	end