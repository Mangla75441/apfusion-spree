Spree::Shipment.class_eval do
	# after_update :update_at_apfusion, if: Proc.new { |shipment| shipment.tracking.present?}

	def update_at_apfusion
		SpreeApfusion::Shipment.update(self)
	end

	

end