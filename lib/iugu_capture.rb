module Iugu
  module Capture
    def capture
      copy Iugu::Factory.create_from_response(self.class.object_type, APIRequest.request('POST', "#{self.class.url(self.id)}/capture"))
      self.errors = nil
      true
    rescue Iugu::RequestWithErrors => ex
      self.errors = ex.errors
      false
    end
  end
end

Iugu::Invoice.include Iugu::Capture
