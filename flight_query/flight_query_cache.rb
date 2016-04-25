# Flight information query cache class
class Cache
	attr_accessor :flight_cache_storage # Flight cache, Implemented as a hash
	CACHE_CAPACITY = 5 # Capacity : 5
	# State constants
	SUCCESS = "success"
	ERROR = "ERROR: FLIGHT_DOESNOT_EXIST"
	FLIGHT_DB = "flight_schedule.txt"
	TAG_DEFAULT_STATUS = "FLIGHT_NOT_FOUND"
	TAG_DEFAULT_ARRIVAL = "CANNOT_RESOLVE_ARRIVAL"
	TAG_DEFAULT_DEPARTURE = "CANNOT_RESOLVE_DEPARTURE"
	TAG_DEFAULT_STOPS = "CANNOT_DETERMINE_STOPS"
	
	# Initialize the cache with flight objects
	def initialize
		@flight_cache_storage = Hash.new # flight_obj_hash
	end
	
	# Perform cache lookup operation
	def lookup_cache(flight_name)
		if @flight_cache_storage.has_key?(flight_name) then # Return flight information from cache, Cache had a hit
			@flight_cache_storage[flight_name].lookup += 1
			return [@flight_cache_storage[flight_name], SUCCESS]
		end
		# In case we encounter a miss, Retrieve flight information from flight database
		flight_obj = Flight.new(TAG_DEFAULT_STATUS, TAG_DEFAULT_ARRIVAL, TAG_DEFAULT_DEPARTURE, TAG_DEFAULT_STOPS)
		File.open(FLIGHT_DB) do |flight_file|
			flight_file.each_line do |flight_info|
				current_selected_flight = flight_info.split
				if current_selected_flight[0] == flight_name then
					flight_obj.name = current_selected_flight[0]
					flight_obj.arrival = current_selected_flight[1]
					flight_obj.departure = current_selected_flight[2]
					flight_obj.stops = current_selected_flight[3]
					flight_obj.lookup = 1
					# If cache capacity reached, Delete the flight detail that had the minimum number of hits or lookups
					if @flight_cache_storage.count == CACHE_CAPACITY then
						min_lup = @flight_cache_storage.first[1].lookup
						flight_name = @flight_cache_storage.keys.first
						@flight_cache_storage.keys.each do |flight_key|
							if @flight_cache_storage[flight_key].lookup < min_lup then
								min_lup = @flight_cache_storage[flight_key].lookup
								flight_name = flight_key
							end
						end
						@flight_cache_storage.delete(flight_name)
					end
					@flight_cache_storage[flight_obj.name] = flight_obj
					return [flight_obj, SUCCESS]
				end
			end
			return [flight_obj, ERROR]
		end
	end
	
	# Clear the entire cache
	def clear_cache
		@flight_cache_storage.clear
	end
	
	# Show cache state
	def cache_state
		p @flight_cache_storage
	end
end

# Flight class implementation
class Flight
	attr_accessor :name, :arrival, :departure, :stops, :lookup # Flight details
	
	# Initialize flight details
	def initialize(name, arrival, departure, stops, lookup=0)
		@name = name
		@arrival = arrival
		@departure = departure
		@stops = stops
		@lookup = lookup
	end
	
	# Show flight details
	def full_flight_details
		puts "FLIGHT_NAME: #{@name}, FLIGHT_ARRIVAL: #{@arrival}, FLIGHT_DEPARTURE: #{@departure}, FLIGHT_STOPS: #{@stops}"
	end
end

# Initialize cache
cache_obj = Cache.new

BOUNDARY_MARKER = 40 # Specifies number of '-' (hyphen's)

# Start Cache
while true do
	print "-" * BOUNDARY_MARKER
	print "\n\nEnter flight to query (Type 'q' to quit): "
	flight_id = gets.chomp
	if flight_id == "q" then
		puts "Quitting program..."
		sleep(2)
		puts "Saving statuses..."
		sleep(3)
		break # Exit from program
	end
	flight_queried, status = cache_obj.lookup_cache(flight_id)
	if status == "success" then
		flight_queried.full_flight_details
	else
		puts status
		flight_queried.full_flight_details
	end
	print "\n\nWould you like to view cache state (Y/N): "
	choice = gets.chomp.upcase
	if(choice == "Y") then
		cache_obj.cache_state
	end
end