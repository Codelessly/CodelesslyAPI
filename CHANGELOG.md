## 9.1.0

- `motion.keyframes` binds to a list of `{t, translateX, translateY, ...}`
  maps (or that list as JSON): keyframes that follow data, such as wind
  gusts along a route that changes when it is redrawn
  (`MotionModel.keyframesProperty`).
- `ShowToastAction.rotation`, `enterCurve` and `enterOffset`: a toast can be
  tilted (a sticky note stuck on crooked) and come in on any motion curve
  from further away (dropping in on easeOutBack). Left out of JSON at their
  defaults.

