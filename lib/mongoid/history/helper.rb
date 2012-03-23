module Mongoid::History
  module Helper
    # private methods below
    def meta
      @meta ||= Mongoid::History.meta(doc.class)
    end

    def association_chain
      @association_chain ||= Association::Chain.build_from_doc(doc)
    end
  end
end
