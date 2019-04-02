Spree::ProductProperty.class_eval do
		# after_create :create_at_apfusion
		# after_update :update_at_apfusion
		# after_destroy :destroy_at_apfusion


		def create_at_apfusion
			SpreeApfusion::ProductProperty.create(self)
		end

		def update_at_apfusion
			SpreeApfusion::ProductProperty.update(self)
		end

		def destroy_at_apfusion
			SpreeApfusion::ProductProperty.destroy(self)
		end

	end