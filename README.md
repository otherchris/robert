# Robert

A Robert's Rules of Order Engine.

- [RulesServer](lib/rules_server.ex) A server that maintains the state of
  a meeting
- [Meeting](lib/Meeting.ex) An abstraction describing the state of a meeting
- [Actions](lib/actions.ex) Things that can happen in a meeting
- [Checks](lib/checks.ex) Assertions about the state of the meeting, who is
  acting, and whom they are acting upon that determine if it can proceed
