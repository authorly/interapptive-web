;(function() {

    var Form = Backbone.Form,
        Base = Form.editors.Base,
        createTemplate = Form.helpers.createTemplate,
        triggerCancellableEvent = Form.helpers.triggerCancellableEvent,
        exports = {};

    //Buttons
    exports.Buttons = Base.extend({

        tagName: 'div',
        className: 'btn-group',


        events: {
            'click .btn-primary': 'setActive'
        },

        initialize: function(options) {
            Base.prototype.initialize.call(this, options);

            this.options = options;
        },

        render: function() {

            var $el = this.$el,
                schema = this.schema,
                buttonType = schema.buttonType,
                labeling = schema.labeling,
                selectedIndex = schema.selectedIndex,
                selector = 'button:contains("' + this.value + '")',
                buttonTypeCssClass;

            switch (buttonType) {
                case "toggle":
                    groupTypeCssClass =  "button";
                    break;
                case "checkbox":
                    groupTypeCssClass =  "buttons-checkbox";
                    break;
                case "radio":
                    groupTypeCssClass =  "button-radio";
                    break;
            }

            $el.attr('data-toggle', groupTypeCssClass);

            if (_.isString(labeling)) {
                html = '<button class="btn">' + labeling + '</button>';
            }

            //Or array
            else if (_.isArray(labeling)) {
                html = this._arrayToHtml(labeling, selectedIndex);
            }

            $el.html(html);

            $el.find(selector).addClass("active");
            $el.find(selector).siblings().removeClass("active");
            //Make sure setValue of this object is called, not of any objects extending it (e.g. DateTime)
            exports.Buttons.prototype.setValue.call(this, this.value);

            return this;
        },

        /**
         * @return {aValue}   Active buttons value
         */
        getValue: function() {
           return this.$el.val();
        },

        setValue: function(value) {
            this.$el.val(value);
        },

        setActive: function(ev) {
            ev.preventDefault();
            $(ev.target).siblings().removeClass("active");
            $(ev.target).addClass("active");
            this.setValue($(ev.target).text());
        },

        /**
         * Create Bootstrap button list HTML
         * @param {Array}   Options as a simple array e.g. ['option1', 'option2']
         *                      or as an array of objects e.g. [{val: 543, label: 'Title for object 543'}]
         * @return {String} HTML
         */
        _arrayToHtml: function (array, indexOfActive) {
            var html = [];
            var self = this;

            _.each(array, function(option, index) {
                var is_active = index == indexOfActive ? true : false
                var button_html = '<button class="btn btn-primary' + (is_active == true ? " active" : "") + '">' + option + '</button>';
                if(is_active == true) self.setValue(option);

                html.push(button_html);
            });

            return html.join('');
        }
    });

    //Exports
    _.extend(Form.editors, exports);

})();