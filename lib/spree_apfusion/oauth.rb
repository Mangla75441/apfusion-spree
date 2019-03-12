module SpreeApfusion
	class OAuth

		def self.init
			# @url = 'http://apfusion.com/'
			# 
			urls = {
				"development" => "http://localhost:3000/",
				"staging" => "http://34.217.121.110/",
				"production" => "https://apfusion.com/"
			}
		 	 	@url = urls[Rails.env]
				@grant_type = 'client_credentials'

			begin
				@apfusion_auth_config = YAML.load_file(Rails.root.to_s + '/config/apfusion_auth_config.yml')[Rails.env]
			rescue
				raise "
				\n===============================================================
				\n Please create a config file at /config/apfusion_auth_config.yml like the example given below
				\n===============================================================
				\ndevelopment:
				\n\tpublic_key: PUBLIC_KEY
				\n\tsecret_key: SECRET_KEY
				\n===============================================================\n"
			end
			# @apfusion_auth_config = YAML.load_file('/Users/afzal/rails/gems/spree_apfusion/config/apfusion_auth_config.yml')[Rails.env]
			@public_key = @apfusion_auth_config['public_key']
			@secret_key = @apfusion_auth_config['secret_key']
			@access_token = ApfusionToken.first.try(:token) || ''
		end

		def self.get_access_token
			begin
				request = RestClient.post(@url+'/oauth/token', {client_id: @public_key, client_secret: @secret_key, grant_type: @grant_type})
				@access_token = JSON.parse(request.body)['access_token']

				SpreeApfusion::OAuth.update_token

				return {success: true}

			rescue => e
				error = e.as_json
				if error.is_a? String
					return {success: false, response: "#{error} - In getting access token."}
				else
					return {success: false, response: JSON.parse(error['response'].body), response_code: error['initial_response_code']}
				end
			end
		end

		def self.update_token
			if ApfusionToken.first.present?
				ApfusionToken.first.update_attributes(token: @access_token)
			else
				ApfusionToken.create(token: @access_token)
			end
		end

		def self.authorize
			SpreeApfusion::OAuth.init
			if @access_token.blank?
				response = SpreeApfusion::OAuth.get_access_token
				unless response[:success]
					return response
				end
			end

			{status: 'Authorized!', access_token: @access_token}
		end

		def self.send (method, url_path, data)
			p '========================'
			p "Method: #{method}"
			p "Url: #{url_path}"
			p "Params: #{data}"
			p '========================'
			SpreeApfusion::OAuth.authorize
			p "after authorize called"
			request = RestClient::Request.new(
				method: method,
				url: @url+url_path+'?access_token='+@access_token,
				headers: {params: data}
			)
			begin
			response = request.execute {|response| $results = response}

			response.body
			
				response_body = JSON.parse(response.body)
			rescue
				response_body = ''
			end

			begin
				
				case response.code.to_s

					when /^20/
						p 'SYNC Successfully'
						return {success: true, response: response_body, response_code: response.code}
					when '401'
						p '!!!!Invalid Access Token!!!!'
						ApfusionToken.destroy_all
						SpreeApfusion::OAuth.send(method, url_path, data)
					else
						return {success: false, response: response_body, response_code: response.code}
				end
			rescue Exception => e
				p e.message
			end
			# p 1
			# SpreeApfusion::OAuth.authorize
			# p 2
			# begin
			# 	p 3
			# 	p method
			# 	request = RestClient.send(method, @url+url_path+'?access_token='+@access_token, data)
			# 	p request.as_json
			# 	if request.present?
			# 		return JSON.parse(request.body)
			# 	else
			# 		return {success: false, response: 'Error! Unable to send data.'}
			# 	end

			# rescue => e
			# 	p 4
			# 	error = e.as_json
			# 	if error == "401 Unauthorized" || error['initial_response_code'] == 401
			# 		ApfusionToken.destroy_all
			# 		SpreeApfusion::OAuth.send(url_path, data)
			# 	else
			# 		if error.is_a? String
			# 			return {success: false, response: "#{error} - In sending data."}
			# 		else
			# 			return {success: false, response: JSON.parse(error['response'].body), response_code: error['initial_response_code']}
			# 		end
			# 	end

			# end
		end

	end
end
