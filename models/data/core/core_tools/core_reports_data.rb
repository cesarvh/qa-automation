class CoreReportsData < CollectionSpaceData

  DATA = [
      REPORT_NAME = new('name'),
      REPORT_DESC = new('notes'),
      REPORT_NO_CONTEXT = new('supportsNoContext'),
      REPORT_SINGLE_CONTEXT = new('supportsSingleDoc'),
      REPORT_LIST_CONTEXT = new('supportsDocList'),
      REPORT_GROUP_CONTEXT = new('supportsSingleDoc'),
      REPORT_DOC_TYPES_GROUP = new('forDocTypes'),
      REPORT_DOC_TYPE = new('forDocType'),
      REPORT_OUTPUT_MIME = new('outputMIME')
  ]

end
