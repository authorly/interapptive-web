// Enables pasting on all elements with .text_widget class
// Uses code from http://jsfiddle.net/nK4eJ/37/
// and
// heavily dependent on "Rangy"

if($.browser.msie || $.browser.opera) { //Ie and Opera don't suppor the paste event as expected. Let's catch ctrl + v. Also disable rightclick. In Opera, this just thros an alert but the context menu still appears.
    var ctrl = false;

    $('.text_widget').keydown(function(e) {
        if(e.which == 17 || e.which == 91) {
            ctrl = true;
            return false;
        }

        if(ctrl && e.which == 86) {
            cleanUp();
        } else {
            ctrl = false;
        }
    });

    $('.text_widget').mousedown(function() {
        if (e.which === 3) {
            alert("Please use CRTL + V for pasting");
        }
    });
} else { //If you got a normal browser, use the paste event
    $(document).on('paste', '.text_widget', function(e) {
        cleanUp();
    });
}

function cleanUp() {
    savedSel = rangy.saveSelection(); //First, save the current cursor position

    $('#cleanUp').focus(); //chagne focus to some element. Positioned out of the window. You can't focus a hidden element

    setTimeout(function() {//Wait, so the pasting was made for sure into the cleanUp div.
        $('.text_widget').focus(); //focus the origin div again
        rangy.restoreSelection(savedSel); //restore the cursor position which was lost when changing the focus
        paste($('#cleanUp').text()); //paste the text at the current cursor position
        $('#cleanUp').empty()
    }, 100);
}

//IE fix. IE doesn't know createContextualFragment,so we'll teach him.
if (typeof Range.prototype.createContextualFragment == "undefined") {
    Range.prototype.createContextualFragment = function(html) {
        var doc = this.startContainer.ownerDocument;
        var container = doc.createElement("div");
        container.innerHTML = html;
        var frag = doc.createDocumentFragment(), n;
        while ( (n = container.firstChild) ) {
            frag.appendChild(n);
        }
        return frag;
    };
}

function paste(html) {
    if (window.getSelection && window.getSelection().getRangeAt) {
        range = window.getSelection().getRangeAt(0);
        node = range.createContextualFragment(html);
        range.insertNode(node);
    } else if (document.selection && document.selection.createRange) {
        document.selection.createRange().pasteHTML(html);
    }
}