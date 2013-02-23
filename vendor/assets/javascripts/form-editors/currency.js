;(function() {

    var Form = Backbone.Form,
        Base = Form.editors.Number,
        createTemplate = Form.helpers.createTemplate,
        triggerCancellableEvent = Form.helpers.triggerCancellableEvent,
        exports = {};

    /**
     * CURRENCY
     * Masks input for currency in the format of XX.XX
     */
    exports.Currency = Base.extend({
        defaultValue: null,


        initialize: function(options) {
            Base.prototype.initialize.call(this, options);

            this.$el.attr('type', 'text');
            this.$el.attr('placeholder', '0.00');
            this.$el.addClass('input-mini');

        },

        /**
         * Check value is positive, numeric, and has no symbols
         */
        onKeyPress: function(event) {
            //Allow backspace
            if (event.charCode == 0) return;

            //Get the whole new value so that we can prevent things like double decimals points etc.
            var newVal = this.$el.val() + String.fromCharCode(event.charCode);

            var matches_currency_format = /^\d+(?:\.\d{0,2})?$/.test(newVal);

            if (!matches_currency_format) event.preventDefault();
        },

        getValue: function() {
            var value = this.$el.val();

            return value === "" ? null : parseFloat(value, 10);
        },

        setValue: function(value) {
            value = value === null ? null : parseFloat(value, 10);

            Base.prototype.setValue.call(this, value);
        }

    });



    //Exports
    _.extend(Form.editors, exports);

})();