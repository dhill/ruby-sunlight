module Sunlight

  class Committee < Base

    attr_accessor :name, :id, :chamber, :subcommittees, :members

    def initialize(params)
      params.each do |key, value|

        case key

        when 'subcommittees'
          self.subcommittees = add_nodes('committee', Sunlight::Committee, value)

        when 'members'
          self.members = add_nodes('legislator', Sunlight::Legislator, value)
    
        else
          instance_variable_set("@#{key}", value) if Committee.instance_methods.map { |m| m.to_sym }.include? key.to_sym
        end
      end
    end
    
    def load_members
      self.members = Sunlight::Committee.get(self.id).members
    end
    
    def add_nodes(type, klass, values)
      values.each_with_object([]) do |value, arr|
        arr << klass.new(value[type])
      end
    end

    # 
    # Usage:
    #   Sunlight::Committee.get("JSPR")     # returns a Committee
    #
    #

    def self.all_where(params)

      url = construct_url("committees", {:id => id})
      
      if (result = get_json_data(url))
        committee = Committee.new(result["response"]["committee"])
      else
        nil # appropriate params not found
      end

    end

  end # class Committee
  
end # module Sunlight
