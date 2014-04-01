/////////////////////////////
///  EMAIL-SCHEDULER GEM ///
///////////////////////////

var Scheduler = (function(){

  function Scheduler (){


    //SERVER PARMS SENT ON SUBMIT//
    this.params = {};

    //INJECT LIGHTWEIGHT jsTimezoneDetect FOR PROVIDING TIME ZONE NAME//
    (function() {
           var script = $('<script></script>').attr({
             type: 'text/javascript',
             async: 'true',
             src: '//cdnjs.cloudflare.com/ajax/libs/jstimezonedetect/1.0.4/jstz.min.js'
             });
           $('body').append(script);
         })();

    //INITIALIZE METHOD//
    (function(this) {

      //BIND ALL SELECTION BLOCKS IN SCHEDULER TO CALLBACK THAT PROCCESSES PARAMS//
      $('.block').on( 'click', this.process_selection.bind(this) );

      //POPULATES MESSAGE ABOVE SCHEDULER FORM WITH APPRPRIATE HTML//
      //USES JSTIMEZONE METHOD TO RETURN NAME OF TIMEZONE//
      //PREVENTS HAVING TO WRITE 200 LINE UTILITY METHOD//
      $('h3.timezone_alert').html('Current local time used for scheduling: ' + jstz.determine().name() );
    })(this);

    Scheduler.prototype.process_selection = function(e) {

      var user_day, server_object, $target, $parent;

      $target = $(e.target);
      $parent = $target.parent();
      user_day = $parent.data('day');
      if ( $target.hasClass('selected') ) {
        $target.removeClass('selected');
        server_object = this.parse_user_date(user_day, $target);
        this.params[ server_object.day ] = "false";
      }
      else {
        $target.siblings().removeClass('selected');
        $target.addClass('selected');
        server_object = this.parse_user_date(user_day, $target);
        this.params[ server_object.day ] = String(server_object.hour);
      }
    }
    Scheduler.prototype.parse_user_date = function(user_day_string, $time_block){

      var UTC_day, server_day, converted_user_day, date, user_hour, server_hour;

      //YIELDS DAY OF MONTH FOR SET WEEK IN MAY 2014 FOR SOLE PURPOSE OF OBTAINING//
      //DATE OBJECT THAT SUITS PURPOSE OF REPRESENTING CLIENT LOCAL DAY SELECTION//
      switch (user_day_string) {
        case: "Sunday":
          converted_user_day = 4;
          break;
        case: "Monday":
          converted_user_day = 5;
          break;
        case: "Tuesday":
          converted_user_day = 6;
          break;
        case: "Wednesday":
          converted_user_day = 7;
          break;
        case: "Thursday":
          converted_user_day = 8;
          break;
        case: "Friday":
          converted_user_day = 9;
          break;
        case: "Saturday":
          converted_user_day = 10;
      }

      //ASSIGNS USER'S DESIRED HOUR/TIME-BLOCK BASED ON DOM CLASS//
      if ( $time_block.hasClass('morning') ) {
        user_hour = "09";
      }
      else if ( $time_block.hasClass('afternoon') ) {
        user_hour = "13";
      }
      else {
        user_hour = "19";
      }

      //CREATE DATE AND PASS IT MOCK MONTH WITH DAY FOR PURPOSE OF OBTAINING//
      date = new Date();
      date.setFullYear(2014, 4, converted_user_day);

      // SET HOUR AND MINUTES TO FINISH CREATING OUR CLIENT TIME-BLOCK DATE REPRESENTATION//
      date.setHours(user_hour, 0);

      //METHOD CALLS THAT RETURN VALUES THAT CORRESPOND WITH SERVER TIME//
      UTC_day = date.getUTCDay();
      server_hour = date.getUTCHours();

      //CONVERT UTC DAY VALUE BACK TO STRING THAT WILL CORRESPOND//
      //TO COLUMN IN DATABASE SCHEDULE TABLE//
      switch (UTC_day) {
        case 0:
          server_day = "sunday";
          break;
        case 1:
          server_day = "monday";
          break;
        case 2:
          server_day ="tuesday";
          break;
        case 3:
          server_day = "wednesday";
          break;
        case 4:
          server_day = "thursday";
          break;
        case 5:
          server_day = "friday";
          break;
        case 6:
          server_day = "saturday";
      }
      return {day: server_day, hour: server_hour}
    }
  }
})();