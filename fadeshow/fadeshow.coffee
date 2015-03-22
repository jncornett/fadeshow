PLUGIN_NAME = 'fadeshow'
console.log "#{PLUGIN_NAME} loaded'
LOG_LEVEL = 'info'

log_levels =
    debug: 0
    info: 1
    warning: 2
    error: 3

log = (level, args...) ->
    if log_levels[level] >= log_levels[LOG_LEVEL]
        console.log "#{PLUGIN_NAME}: #{level}:", args...

    
class FadeShow
    constructor: (@el, options) ->
        @$el = $ @el
        @options = $.extend @defaults, @$el.data(), options

        @$slides = @$el.children @options.slideSelector

        @nextCallback = @callbacks[@options.nextCallback] or @options.nextCallback
        @inCallback = @callbacks[@options.inCallback] or @options.inCallback
        @outCallback = @callbacks[@options.outCallback] or @options.outCallback
        @index = @options.startIndex or 0

        @setContainerStyle()
        @setSlideStyle()

        if @options.start
            @start()

    setContainerStyle: ->
        containerStyle = @options.containerStyle
        if @options.width?
            containerStyle.width = parseInt @options.width

        if @options.height?
            containerStyle.height = parseInt @options.height

        log 'debug', 'containerStyle()', containerStyle
        @$el.css containerStyle

    setSlideStyle: ->
        slideStyle = $.extend {}, @options.slideStyle
        startIndex = @index

        switch @options.fit
            when 'stretch'
                slideStyle.height ?= @$el.innerHeight()
                slideStyle.width ?= @$el.innerWidth()
            when 'width'
                slideStyle.width ?= @$el.innerWidth()
            when 'height'
                slideStyle.height ?= @$el.innerHeight()

        switch @options.align
            when 'corner'
                slideStyle.top ?= 0
                slideStyle.left ?= 0

        @$slides.css slideStyle
        @$slides.not(@$slides.first()).css "display", "none"

    start: ->
        if @ival?
            log 'warning', 'start() already called on object for element, call stop() first', @el
            @stop()
        else
            @ival = setInterval @next.bind(@), parseInt @options.interval

    stop: ->
        clearInterval @ival
        @ival = null

    started: -> @ival?

    next: ->
        @show @nextCallback.call @

    show: (newIndex) ->
        log 'debug', "show(#{newIndex})"
        if newIndex?
            if newIndex isnt @index
                @outCallback.call @, @$slides[@index]
                @index = newIndex
                @inCallback.call @, @$slides[@index]
            else
                log 'debug', 'show() called with same index, doing nothing'

        else
            log 'warning', 'show() called with null index, doing nothing'

    defaults:
        nextCallback: "cycle"
        outCallback: "fadeOut"
        inCallback: "fadeIn"
        interval: 1000
        startIndex: 0
        slideSelector: "img"
        containerStyle:
            overflow: "hidden"
            display: "block"
            position: "relative"
        slideStyle:
            position: "absolute"

    callbacks:
        cycle: -> ( @index + 1 ) % @$slides.length
        shuffle: ->
            index = Math.floor Math.random() * ( @$slides.length - 1 )
            if index >= @index
                index++

            index

        fadeOut: (el) -> $(el).fadeOut()
        fadeIn: (el) -> $(el).fadeIn()


$.fn[PLUGIN_NAME] = (options, args...) ->
    rv = []
    @each ->
        if @[PLUGIN_NAME]?
            rv.push @[PLUGIN_NAME][options].apply @[PLUGIN_NAME], args
        else
            @[PLUGIN_NAME] = new FadeShow @, options

    rv[0]
