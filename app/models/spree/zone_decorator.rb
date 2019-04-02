Spree::Zone.class_eval do
	# after_create :create_at_apfusion
	# after_update :update_at_apfusion
	# after_destroy :destroy_at_apfusion
	



	
	def create_at_apfusion
		SpreeApfusion::Zone.create(self)
	end


	def update_at_apfusion
		SpreeApfusion::Zone.update(self)
	end

	def destroy_at_apfusion
		SpreeApfusion::Zone.destroy(self)
	end
end