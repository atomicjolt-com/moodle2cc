module Moodle2AA::Learnosity::Models
  class Export
    include JsonWriter
    attr_accessor :meta, :activities, :items, :questions, :_item_groups, :files, :features
    def initialize
      @meta = []
      @activities = []
      @items = []
      @questions = []
      @features = []
      @_item_groups = []
      @files = []
    end


    def to_json
      JSON.generate({
        activities: @activities,
        items: @items,
        questions: @questions,
        features: @features,
      })
    end
  end
end
