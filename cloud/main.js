// Always send a background push after a chat
Parse.Cloud.afterSave("Chat", function(request) {
  Parse.Push.send({
    data: {
      alert: request.object.get("text"),
      "content-available": 1,
    },
    where: new Parse.Query(Parse.Installation)
  });
});
