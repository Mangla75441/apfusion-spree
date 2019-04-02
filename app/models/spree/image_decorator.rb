Spree::Image.class_eval do
		# after_commit ->(obj) {obj.create_at_apfusion}, on: :create
		# after_commit ->(obj) {obj.update_at_apfusion}, on: :update
		# after_destroy :destroy_at_apfusion

		def create_at_apfusion
			SpreeApfusion::Image.create(self)
		end

		def update_at_apfusion
			SpreeApfusion::Image.update(self)
		end

		def destroy_at_apfusion
			SpreeApfusion::Image.destroy(self)
		end

		def self.create_all_images
			Spree::Image.all.each do |image|
				SpreeApfusion::Image.create(image)
			end		

		end

	end