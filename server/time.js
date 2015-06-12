if(Meteor.isServer) {
  Meteor.startup(function () {
    // Global configuration
    Restivus.configure({
      useAuth: false,
      prettyJson: true
    });

    Restivus.addRoute('time', {authRequired: false}, {
      get: {
        action: function () {
          return { status: "success", data: {time: Date.now()}};
        }
      }
    });
  });
}
