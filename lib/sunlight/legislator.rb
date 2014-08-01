module Sunlight

  class Legislator < Base


    attr_accessor :title, :firstname, :middlename, :lastname, :name_suffix, :nickname,
                  :party, :state, :district, :in_office, :gender, :phone, :fax, :website, :contact_form,
                  :email, :congress_office, :bioguide_id, :votesmart_id, :fec_id, :leadership_role,
                  :govtrack_id, :crp_id, :congresspedia_url, :twitter_id, :youtube_url, :facebook_id,
                  :senate_class, :birthdate, :term_start, :term_end, :terms, :fuzzy_score

    # Takes in a hash where the keys are strings (the format passed in by the JSON parser)
    #
    def initialize(params)
      params.each do |key, value|
        value = Time.parse(value) if key == "birthdate" && value && value.size > 0
        instance_variable_set("@#{key}", value) if Legislator.instance_methods.map { |m| m.to_sym }.include? key.to_sym
      end
    end
    
    # Convenience method for getting out the youtube_id from the youtube_url
    def youtube_id
      /http:\/\/(?:www\.)?youtube\.com\/(?:user\/)?(.*?)\/?$/.match(youtube_url)[1] unless youtube_url.nil?
    end
    
    # Get the committees the Legislator sits on
    #
    # Returns:
    #
    # An array of Committee objects, each possibly
    # having its own subarray of subcommittees
    def committees
      url = Sunlight::Base.construct_url("committees", {:bioguide_id => self.bioguide_id})

       if (result = Sunlight::Base.get_json_data(url))
         committees = []
         result["response"]["committees"].each do |committee|
           committees << Sunlight::Committee.new(committee["committee"])
         end
       else
         nil # appropriate params not found
       end
       committees
    end

    #
    # Useful for getting the exact Legislators for a given district.
    #
    # Returns:
    #
    # A Hash of the three Members of Congress for a given District: Two
    # Senators and one Representative.
    #
    # You can pass in lat/long or address. The district will be
    # determined for you:
    #
    #   officials = Legislator.all_for(:latitude => 33.876145, :longitude => -84.453789)
    #   senior = officials[:senior_senator]
    #   junior = officials[:junior_senator]
    #   rep = officials[:representative]
    #
    #   Sunlight::Legislator.all_for(:address => "123 Fifth Ave New York, NY 10003")
    #   Sunlight::Legislator.all_for(:address => "90210") # it'll work, but use all_in_zip instead
    #
    def self.all_for(params)

      if (params[:latitude] and params[:longitude])
        Legislator.all_in_district(District.get(:latitude => params[:latitude], :longitude => params[:longitude]))
      elsif (params[:address])
        Legislator.all_in_district(District.get(:address => params[:address]))
      else
        nil # appropriate params not found
      end

    end


    #
    # A helper method for all_for. Use that instead, unless you 
    # already have the district object, then use this.
    #
    # Usage:
    #
    #   officials = Sunlight::Legislator.all_in_district(District.new("NJ", "7"))
    #
    def self.all_in_district(district)

      senior_senator = Legislator.all_where(:state => district.state, :district => "Senior Seat").first
      junior_senator = Legislator.all_where(:state => district.state, :district => "Junior Seat").first
      representative = Legislator.all_where(:state => district.state, :district => district.number).first

      {:senior_senator => senior_senator, :junior_senator => junior_senator, :representative => representative}

    end


    #
    # A more general, open-ended search on Legislators than #all_for.
    # See the Sunlight API for list of conditions and values:
    #
    #
    # Returns:
    #
    # An array of Legislator objects that matches the conditions
    #
    # Usage:
    #
    #   johns = Sunlight::Legislator.all_where(:firstname => "John")
    #   floridians = Sunlight::Legislator.all_where(:state => "FL")
    #   dudes = Sunlight::Legislator.all_where(:gender => "M")
    #
    def self.all_where(params)

      url = construct_url("legislators", params)
      legislators_from_url(url)
    end
    
    #
    # Takes either { zip: ##### } or { latitude: XXX.XXXX, longitude: XXX.XXXX }
    #
    def self.locate(params)

      url = construct_url("legislators/locate", {:zip => zipcode})

      legislators_from_url(url)

    end # def self.all_in_zipcode
    
    
    def self.legislators_from_url(url)
      if (result = get_json_data(url))
        legislators = []
        result["results"].each do |legislator|
          legislators << Legislator.new(legislator)
        end

        legislators

      else  
        nil
      end # if response.class
    end
    
  end # class Legislator

end # module Sunlight
