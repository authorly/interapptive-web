(function(window) {

// Airbrake shim that stores exceptions until Airbrake notifier is loaded.
window.Airbrake = [];

// Wraps passed function and returns new function that catches and
// reports unhandled exceptions.
Airbrake.wrap = function(fn, stack) {
  var airbrakeWrap = function() {
    try {
      return fn.apply(this, arguments);
    } catch (exc) {
      args = Array.prototype.slice.call(arguments);

      params = { arguments: args }
      if (stack) {
        params.stack = _.map(stack, function (trace) {
          return trace.function + " " + trace.file + ":" + trace.line}
        )
      }
      Airbrake.push({ error: exc, params: params });
    }
  }
  return airbrakeWrap;
}

// Reports unhandled exceptions.
window.onerror = function(message, file, line) {
  Airbrake.push({error: {message: message, fileName: file, lineNumber: line}});
}

var loadAirbrakeNotifier = function() {
  var script = document.createElement('script'),
      sibling = document.getElementsByTagName('script')[0];
  script.src = 'https://ssljscdn.airbrake.io/0.3/airbrake.min.js';
  sibling.parentNode.insertBefore(script, sibling);
}

// Asynchronously loads Airbrake notifier.
if (window.addEventListener) {
  window.addEventListener('load', loadAirbrakeNotifier, false);
} else {
  window.attachEvent('onload', loadAirbrakeNotifier);
}

// Not taken into account without setTimeout. @dira 2014-02-12
setTimeout(function() {
  // Reports exceptions thrown in jQuery event handlers.
  var jqEventAdd = jQuery.event.add;
  jQuery.event.add = function(elem, types, fn, data, selector) {
    var wrapper = Airbrake.wrap(fn);
    // Set the guid of unique handler to the same of original handler, so it can be removed
    wrapper.guid = fn.guid || (fn.guid = jQuery.guid++);
    return jqEventAdd(elem, types, wrapper, data, selector);
  }

  // Reports exceptions thrown in jQuery callbacks.
  var jqCallbacks = jQuery.Callbacks;
  jQuery.Callbacks = function(options) {
    var cb = jqCallbacks(options),
        cbAdd = cb.add;
    cb.add = function() {
      var fns = arguments;
      jQuery.each(fns, function(i, fn) {
        if (jQuery.isFunction(fn)) {
          fns[i] = Airbrake.wrap(fn);
        }
      });
      return cbAdd.apply(this, fns);
    }
    return cb;
  }

}, 0);

})(window);

// Reports stacktraces for exceptions thrown in setTimeout callbacks
var oldTimeout = window.setTimeout;
window.setTimeout = function(fn, time) {
  exception = null;
  // trigger an exception to have the current stacktrace
  try {
    a = 0; a.errorInTimeout()
  } catch (exc) {
    exception = exc
  }
  stack = null;
  if (Airbrake._processor != undefined) {
    Airbrake._processor(exception, function(name, errInfo) {
      return (errInfo.backtrace)
    })
  }
  oldTimeout(Airbrake.wrap(fn, stack), time);
}
