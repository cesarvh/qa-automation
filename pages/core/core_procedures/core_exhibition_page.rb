require_relative '../../../spec_helper'

class CoreExhibitionPage

  include Logging
  include Page
  include CollectionSpacePages
  include CoreSidebar
  include CoreExhibitionInfoForm

  DEPLOYMENT = Deployment::CORE

end
