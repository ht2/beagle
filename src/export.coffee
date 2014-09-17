beagle =
    walk: (callback, params = {}, scope) ->
        scope = scope or window
        (scope.onhashchange = () -> callback(params, scope.location.hash.slice(1)))()
    routes: (() ->
        pathToArray = (path) -> path.split('/')

        clone = (obj) ->
            Clone = ->
            Clone.prototype = obj
            () -> new Clone()

        addModifiedParam = (params, route, path, modifiers) ->
            key = route.slice(1)
            modifier = modifiers[key] or (value) -> value
            params[key] = modifier(path)

        isWildcard = (arr = []) -> arr[arr.length - 1] is '*'

        matchRoute = (route, pathArray, params, modifiers) ->
            match = true
            routeParts = pathToArray(route)

            routeParts.forEach((routePart, index) ->
                pathPart = pathArray[index]

                # If the route part is a param then add the path part as a param.
                if routePart[0] is ':' then addModifiedParam(params, routePart, pathPart, modifiers)

                # If the route part isn't a wildcard or a path then path doesn't match.
                else if not ((routePart is '*') or (routePart is pathPart)) then match = false
            )

            match = match and (routeParts.length is pathArray.length or isWildcard(routeParts))
            pathArray.splice(0, routeParts.length - !!isWildcard(routeParts))
            match

        (routes = {}, modifiers = {}) -> (params = {}, path = '') ->
            pathArray = pathToArray(path)
            params = clone(params)

            for route, callback of routes
                newParams = params()
                newPath = pathArray.concat()
                if matchRoute(route, newPath, newParams, modifiers)
                    callback(newParams, newPath.join('/'))
    )()

# AMD Support.
if typeof this.define is 'function'
    this.define('beagle', [], beagle)
else this.beagle = beagle
