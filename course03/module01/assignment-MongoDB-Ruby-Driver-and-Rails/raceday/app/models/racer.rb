class Racer 
	include ActiveModel::Model

	attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs

	def initialize(params={})
		@id = params[:_id].nil? ? params[:id] : params[:_id].to_s
		@number = params[:number].to_i
		@first_name = params[:first_name]
		@last_name = params[:last_name]
		@gender = params[:gender]
		@group = params[:group]
		@secs = params[:secs].to_i
	end

	def self.mongo_client
		Mongoid::Clients.default
	end

	def self.collection
		self.mongo_client[:racers]
	end

	def self.all prototype={}, sort={number: 1}, skip=0, limit=nil
		result = self.collection.find(prototype).sort(sort).skip(skip)
		if (!limit.nil?)
			result = result.limit(limit)
		end
		result
	end

	def self.find id
		result = self.collection.find(_id: BSON::ObjectId.from_string(id)).first
		return result.nil? ? nil : Racer.new(result)
	end

	def save
		result = self.class.collection.insert_one(
			number: @number.to_i,
			first_name: @first_name,
			last_name: @last_name,
			gender: @gender,
			group: @group,
			secs: @secs.to_i)
		@id = result.inserted_id.to_s
	end
	
	def update(params)
		@number = params[:number].to_i
		@first_name = params[:first_name]
		@last_name = params[:last_name]
		@gender = params[:gender]
		@group = params[:group]
		@secs = params[:secs].to_i
		params.slice!(:number, :first_name, :last_name, :gender, :group, :secs)
		self.class.collection.find_one_and_update({_id: BSON::ObjectId.from_string(@id)}, params)
	end

	def destroy
		self.class.collection.find_one_and_delete number: @number
	end

	def persisted?
		!@id.nil?
	end

	def created_at
	end

	def updated_at
	end

	def self.paginate(params)
		page = (params[:page] || 1).to_i || 1
		limit = (params[:per_page] || 30).to_i || 30
		skip = (page - 1) * limit
		query = self.all({}, {}, skip, limit)
		total = query.count
		racers = query.map do |hash| Racer.new hash end
		WillPaginate::Collection.create(page, limit, total) do |pager|
			pager.replace(racers)
		end
	end

end