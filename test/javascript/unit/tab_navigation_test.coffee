beforeEach ->
  fixture.load("../fixtures/tab_navigation_test_fixture.html")
  @tabNav = new Codetriage.TabNavigation()

afterEach ->
  window.location.hash = ""

describe "Codetriage.TabNavigation", ->
  describe "constructor", ->
    it "should set tabNav", ->
      assertjs.equal("3", @tabNav.tabItem.length, "should have found 'a[data-toggle]' 3 times in fixture")

    it "should set locationHash", ->
      window.location.hash = "#ruby"
      assertjs.equal("#ruby", @tabNav.locationHash)

  describe "#defaultLocation", ->
    beforeEach ->
      @defaultLocationSpy = sinon.spy(Codetriage.TabNavigation.prototype, 'defaultLocation')

    afterEach ->
      Codetriage.TabNavigation.prototype.defaultLocation.restore()

    it "should call #defaultLocation", ->
      new Codetriage.TabNavigation()
      assertjs.equal(1, @defaultLocationSpy.callCount)

    it "should not call #defaultLocation when locationHash present", ->
      window.location.hash = "#javascript"
      new Codetriage.TabNavigation()
      assertjs.equal(0, @defaultLocationSpy.callCount)

  describe "#watchHistory", ->
    it "should call #watchHistory", ->
      @watchHistorySpy = sinon.spy(Codetriage.TabNavigation.prototype, 'watchHistory')
      new Codetriage.TabNavigation()
      assertjs.equal(1, @watchHistorySpy.callCount)
      Codetriage.TabNavigation.prototype.watchHistory.restore()

    it "should call #showTabLocation when window popstate event is triggered", ->
      @watchShowTabLocation = sinon.spy(Codetriage.TabNavigation.prototype, 'showTabLocation')
      new Codetriage.TabNavigation()
      $(window).trigger('popstate')
      assertjs.equal(true, @watchShowTabLocation.called)
      Codetriage.TabNavigation.prototype.showTabLocation.restore()

  describe "#bindDataToggleTabEvent", ->
    it "should update locationHash with tabItem is clicked", ->
      $('#go_tab').click()
      assertjs.equal('#go', @tabNav.locationHash)

    it "should call #showTabLocation when tabItem is clicked", ->
      @watchShowTabLocation = sinon.spy(Codetriage.TabNavigation.prototype, 'showTabLocation')
      $('#go_tab').click()
      assertjs.equal(true, @watchShowTabLocation.called)
      Codetriage.TabNavigation.prototype.showTabLocation.restore()

  describe "#showTabLocation", ->
    it "should show content with an ID that matches the locationHash", ->
      $('#javascript_tab').click()
      assertjs.equal(true, $("#javascript").hasClass('active'))