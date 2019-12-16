class ErrorSerializer
  def initialize(model)
    @model = model
    @errors = []
    call
  end

  def call
    @model.errors.messages.each do |field, model_errors|
      model_errors.each do |error_message|
        errors << {
          status: "422",
          source: {pointer: "/data/attributes/#{field}"},
          title: "Invalid Attribute",
          detail: error_message
        }
      end
    end

    serialize
  end

  def serialize
    { errors: errors }
  end

  private
    attr_accessor :errors
end