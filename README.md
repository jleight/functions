functions
=========

> My Azure function definitions.


Functions
---------

Each function exists in the root of this repository with a prefix based on the
function's trigger.

### timer-trello-autoarchive

This function connects to my Tasks [Trello](https://trello.com/) board and
archives all cards in the "Done" list that haven't been modified in the last
14 days. This function is scheduled to run every week.
