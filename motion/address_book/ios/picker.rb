module AddressBook
  class Picker
    class << self
      attr_accessor :showing
    end
    def self.show(options = nil, &after)
      raise "Cannot show two Pickers" if showing?
      @picker = Picker.new(options, &after)
      @picker.show
      @picker
    end

    def self.showing?
      !!showing
    end

    def initialize(options = nil, &after)
      @options = options || {}
      @after = after
    end

    def show
      self.class.showing = true
      completion = nil
      if @options[:autofocus_search]
        completion = proc{
          @people_picker_ctlr.visibleViewController.searchDisplayController.searchBar.becomeFirstResponder
          @people_picker_ctlr.visibleViewController.searchDisplayController.setActive(true, animated:true);
        }
      end

      @people_picker_ctlr = ABPeoplePickerNavigationController.alloc.init
      @people_picker_ctlr.peoplePickerDelegate = self
      UIApplication.sharedApplication.keyWindow.rootViewController.presentViewController(@people_picker_ctlr, animated:true, completion:completion)
    end

    def hide(ab_person=nil)
      person = ab_person ? AddressBook::Person.new({}, ab_person) : nil

      UIApplication.sharedApplication.keyWindow.rootViewController.dismissViewControllerAnimated(true, completion:lambda{
        @after.call(person) if @after
        self.class.showing = false
      })
    end

    def peoplePickerNavigationController(people_picker, shouldContinueAfterSelectingPerson:ab_person)
      hide(ab_person)
      false
    end

    def peoplePickerNavigationController(people_picker, shouldContinueAfterSelectingPerson:ab_person, property:property, identifier:id)
      hide(ab_person)
      false
    end

    def peoplePickerNavigationControllerDidCancel(people_picker)
      hide
    end
  end
end

module AddressBook
  module_function
  def pick(options = nil, &after)
    AddressBook::Picker.show options, &after
  end
end

