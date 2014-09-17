beagle =
    walk: (callback, params = {}, scope) ->
        scope = scope or window
        (scope.onhashchange = () -> callback(params, scope.location.hash.slice(1)))()
    routes: (() ->
        pathToArray = (path) -> path.split('/')

        copyParams = (params) ->
            Params = ->
            Params.prototype = params
            () -> new Params()

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

            match and (routeParts.length is pathArray.length or isWildcard(routeParts))


        newPath = (path, route) -> path.slice(route.length - !!(isWildcard(route)))

        (routes = {}, modifiers = {}) -> (params = {}, path = '') ->
            pathArray = pathToArray(path)
            params = copyParams(params)

            for route, callback of routes
                newParams = params()
                if matchRoute(route, pathArray, newParams, modifiers)
                    callback(newParams, newPath(path, route))
    )()

# AMD Support.
if typeof this.define is 'function'
    this.define('beagle', [], beagle)
else this.beagle = beagle
