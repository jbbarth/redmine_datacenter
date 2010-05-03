require_dependency 'tabular_form_builder'

#fixes 500 error due to a problem in Redmine core
#see: http://www.redmine.org/issues/5416
class TabularFormBuilder
  def fields_for(*args,&block)
    super(*args,&block)
  end
end
