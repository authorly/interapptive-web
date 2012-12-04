(function($){
    $.fn.getOffsets = function(options) {
        var defaults = {
            directions : ['left', 'right', 'top', 'bottom'],
            offsetOfParent : false
        }
        var options = $.extend(defaults, options);

        var distances = [];
        var obj = $(this);
        objectOffset = obj.offset();
        objectPosition = obj.position();

        if(options.offsetOfParent == true)
        {
            if($.inArray('left',options.directions) !== -1)
            {
                leftOffsetInPixels = objectPosition.left;
                distances.push(leftOffsetInPixels);
            }
            if($.inArray('right',options.directions) !== -1)
            {
                windowWidth = $(window).outerWidth();
                objectWidth = $(obj).width();
                objectOffsetLeft = objectPosition.left;
                rightOffsetInPixels = windowWidth - objectWidth - objectOffsetLeft;
                distances.push(rightOffsetInPixels);
            }
            if($.inArray('top',options.directions) !== -1)
            {
                topOffsetInPixels = objectPosition.top;
                distances.push(topOffsetInPixels);
            }
            if($.inArray('bottom',options.directions) !== -1)
            {
                windowHeight = $(window).outerHeight();
                objectHeight = $(obj).height();
                objectOffsetTop = objectPosition.top;
                bottomOffsetInPixels = windowHeight - objectHeight - objectOffsetTop;
                distances.push(bottomOffsetInPixels);
            }

            return distances;
        }
        else
        {
            if($.inArray('left',options.directions) !== -1)
            {
                leftOffsetInPixels = objectOffset.left;
                distances.push(leftOffsetInPixels);
            }
            if($.inArray('right',options.directions) !== -1)
            {
                windowWidth = $(window).outerWidth();
                objectWidth = $(obj).width();
                objectOffsetLeft = objectOffset.left;
                rightOffsetInPixels = windowWidth - objectWidth - objectOffsetLeft;
                distances.push(rightOffsetInPixels);
            }
            if($.inArray('top',options.directions) !== -1)
            {
                topOffsetInPixels = objectOffset.top;
                distances.push(topOffsetInPixels);
            }
            if($.inArray('bottom',options.directions) !== -1)
            {
                windowHeight = $(window).outerHeight();
                objectHeight = $(obj).height();
                objectOffsetTop = objectOffset.top;
                bottomOffsetInPixels = windowHeight - objectHeight - objectOffsetTop;
                distances.push(bottomOffsetInPixels);
            }

            return distances;
        }
    };
})(jQuery);