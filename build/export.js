(function() {
  var beagle;

  beagle = {
    walk: function(callback, params) {
      if (params == null) {
        params = {};
      }
      return (window.onhashchange = function() {
        return callback(params, location.hash.slice(1));
      })();
    },
    routes: (function() {
      var addModifiedParam, copyParams, isWildcard, matchRoute, newPath, pathToArray;
      pathToArray = function(path) {
        return path.split('/');
      };
      copyParams = function(params) {
        var Params;
        Params = function() {};
        Params.prototype = params;
        return function() {
          return new Params();
        };
      };
      addModifiedParam = function(params, route, path, modifiers) {
        var key, modifier;
        key = route.slice(1);
        modifier = modifiers[key] || function(value) {
          return value;
        };
        return params[key] = modifier(path);
      };
      isWildcard = function(arr) {
        if (arr == null) {
          arr = [];
        }
        return arr[arr.length - 1] === '*';
      };
      matchRoute = function(route, pathArray, params, modifiers) {
        var match, routeParts;
        match = true;
        routeParts = pathToArray(route);
        routeParts.forEach(function(routePart, index) {
          var pathPart;
          pathPart = pathArray[index];
          if (routePart[0] === ':') {
            return addModifiedParam(params, routePart, pathPart, modifiers);
          } else if (!((routePart === '*') || (routePart === pathPart))) {
            return match = false;
          }
        });
        return match && (routeParts.length === pathArray.length || isWildcard(routeParts));
      };
      newPath = function(path, route) {
        return path.slice(route.length - !!(isWildcard(route)));
      };
      return function(routes, modifiers) {
        if (routes == null) {
          routes = {};
        }
        if (modifiers == null) {
          modifiers = {};
        }
        return function(params, path) {
          var callback, newParams, pathArray, route, _results;
          if (params == null) {
            params = {};
          }
          if (path == null) {
            path = '';
          }
          pathArray = pathToArray(path);
          params = copyParams(params);
          _results = [];
          for (route in routes) {
            callback = routes[route];
            newParams = params();
            if (matchRoute(route, pathArray, newParams, modifiers)) {
              _results.push(callback(newParams, newPath(path, route)));
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        };
      };
    })()
  };

  if (typeof this.define === 'function') {
    this.define('beagle', [], beagle);
  } else {
    this.beagle = beagle;
  }

}).call(this);
