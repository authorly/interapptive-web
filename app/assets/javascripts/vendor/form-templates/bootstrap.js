;(function() {
    var templates = {
        form: '\
      <form class="form-horizontal">\
        {{fieldsets}}\
        <div class="form-actions">\
         <button class="btn btn-danger left">Delete</button>\
         <button class="btn btn-submit-cancel">Cancel</button>\
         <button type="submit" class="btn btn-primary btn-submit">\
            Save\
         </button>\
        </div>\
      </form>\
    ',

        fieldset: '\
      <fieldset>\
        {{legend}}\
        {{fields}}\
      </fieldset>\
    ',

        field: '\
      <div class="control-group">\
        <label class="control-label" for="{{id}}">{{title}}</label>\
        <div class="controls">\
          {{editor}}\
          <div class="help-inline">{{help}}</div>\
        </div>\
      </div>\
    ',

        currencyField: '\
      <div class="control-group">\
        <label class="control-label" for="{{id}}">{{title}}</label>\
        <div class="controls">\
          <div class="input-prepend input-append"><span class="add-on">$</span>{{editor}}</div>\
          <div class="help-inline">{{help}}</div>\
        </div>\
      </div>\
    '
    };

    var classNames = {
        error: 'error'
    };

    Backbone.Form.helpers.setTemplates(templates, classNames);
})();
