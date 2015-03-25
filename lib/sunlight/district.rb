module Sunlight

  class District < Base

    attr_accessor :state, :number

    def initialize(state, number)
      @state = state
      @number = number.to_i.to_s
    end


    # Usage:
    #   Sunlight::District.get(:latitude => 33.876145, :longitude => -84.453789)    # returns one District object or nil
    #   Sunlight::District.get(:address => "123 Fifth Ave New York, NY")     # returns one District object or nil
    #
    def self.get(params)

      if (params[:latitude] and params[:longitude])

        get_from_lat_long(params[:latitude], params[:longitude])

      elsif (params[:address])

        # get the lat/long from Google
        placemarks = Geocoder.search(params[:address])

        unless placemarks.empty?
          placemark = placemarks[0]
          get_from_lat_long(placemark.latitude, placemark.longitude)
        end

      else
        nil # appropriate params not found
      end

    end



    # Usage:
    #   Sunlight::District.get_from_lat_long(-123, 123)   # returns District object or nil
    #
    def self.get_from_lat_long(latitude, longitude)

      url = construct_url("districts/locate", {:latitude => latitude, :longitude => longitude})

      districts = districts_from_url(url)

      districts ? districts.first : nil

    end


    # Usage:
    #   Sunlight::District.all_from_zipcode(90210)    # returns array of District objects
    #
    def self.all_from_zipcode(zipcode)

      url = construct_url("districts/locate", {:zip => zipcode})

      districts_from_url(url)
    end

    def self.districts_from_url(url)

      if (result = get_json_data(url))

        districts = []
        result["results"].each do |district|
          districts << District.new(district["state"], district["district"])
        end

        districts

      else  
        nil
      end # if response.class

    end


  end # class District

end # module Sunlight
