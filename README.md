appstate
========

This is a little toy prototype exploring the idea that each client shares a single JSON object with the server.
Both the client and the server can read & edit the session object using OT. The object has all the data the client
needs to know to run the app.

This means you can split your app into two parts:

- The client part translates between the session JSON object and HTML / DOM. User interaction edits the JSON object,
and when the object is edited on the server, the client updates the webpage.
- The server part embeds data from the database into the session object. When those documents are edited, it
modifies the original data in the database. (And vice versa)

My prototype is only a few hundred lines in total, which is very nice.
(It depends on the JSON OT type but not sharejs). But its not complete. Its a very nice example of how you can
use the JSON type and do OT yourself though.

Enjoy!

---

(Published under the standard ISC license.)
