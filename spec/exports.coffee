beagle = require('../build/export').beagle

# Tests normal couple.
describe('beagle', () ->
    test =
        params:
            num: 1
        modifiers:
            num2: (param) -> Number(param) + 1
        routes: ->
        walk: ->
        scope: {}

    route = {}

    beforeEach(() ->
        # Reset route.
        route =
            type: ''
            params: {}
            path: ''

        # Route functions.
        testRoute = (type) -> (params, path) ->
            route.type = type
            route.params = params
            route.path = path

        wildRoute = testRoute('a')
        paramRoute = testRoute('b')
        stringRoute = testRoute('c')

        # Basic setup.
        test.routes = beagle.routes({
            'a/*': wildRoute
            'b/:num2': paramRoute
            'c': stringRoute
        }, test.modifiers)
    )

    describe('.routes()', () ->
        it('should call wildcard route when exact match is provided', () ->
            test.routes(test.params, 'a')
            expect(route.type).toBe('a')
            expect(route.path).toBe('')
            expect(route.params.num).toBe(test.params.num)
        )
        it('should call wildcard route when wildcard match is provided', () ->
            test.routes(test.params, 'a/hello')
            expect(route.type).toBe('a')
            expect(route.path).toBe('hello')
            expect(route.params.num).toBe(test.params.num)
        )

        it('should call param route when param match is provided', () ->
            test.routes(test.params, "b/#{test.params.num}")
            expect(route.type).toBe('b')
            expect(route.path).toBe('')
            expect(route.params.num).toBe(test.params.num)
            expect(route.params.num2).toBe(test.params.num + 1)
        )

        it('should call string route when string match is provided', () ->
            test.routes(test.params, 'c')
            expect(route.type).toBe('c')
            expect(route.path).toBe('')
            expect(route.params.num).toBe(test.params.num)
        )
    )

    describe('.walk()', () ->
        beforeEach(() ->
            test.scope =
                onhashchange: ->
                location:
                    hash: ''
            test.walk = beagle.walk(test.routes, test.params, test.scope)
        )

        it('should call wildcard route when exact match is provided', () ->
            test.scope.location.hash = '#a'
            test.scope.onhashchange()
            expect(route.type).toBe('a')
            expect(route.path).toBe('')
            expect(route.params.num).toBe(test.params.num)
        )
        it('should call wildcard route when wildcard match is provided', () ->
            test.scope.location.hash = '#a/hello'
            test.scope.onhashchange()
            expect(route.type).toBe('a')
            expect(route.path).toBe('hello')
            expect(route.params.num).toBe(test.params.num)
        )

        it('should call param route when param match is provided', () ->
            test.scope.location.hash = "#b/#{test.params.num}"
            test.scope.onhashchange()
            expect(route.type).toBe('b')
            expect(route.path).toBe('')
            expect(route.params.num).toBe(test.params.num)
            expect(route.params.num2).toBe(test.params.num + 1)
        )

        it('should call string route when string match is provided', () ->
            test.scope.location.hash = '#c'
            test.scope.onhashchange()
            expect(route.type).toBe('c')
            expect(route.path).toBe('')
            expect(route.params.num).toBe(test.params.num)
        )
    )
)
