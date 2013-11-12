;(function() {
    var templates = {
        form: '\
      <form class="form-horizontal">\
        {{fieldsets}}\
        <div class="form-actions">\
         <input type="button" class="btn btn-submit-cancel" value="Cancel"></input>\
         <button type="submit" class="btn btn-primary btn-submit">\
            Submit\
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
          <div class="help-inline"><div class="bbf-tmp-error" data-error></div></div>\
        </div>\
      </div>\
    ',

        currencyField: '\
      <div class="control-group">\
        <label class="control-label" for="{{id}}">{{title}}</label>\
        <div class="controls">\
          <div class="input-prepend input-append"><span class="add-on">$</span>{{editor}}</div>\
          <div class="help-inline">{{help}}</div>\
          <div class="help-inline"><div class="bbf-tmp-error" data-error></div></div>\
        </div>\
      </div>\
    '
    };

    var classNames = {
        error: 'error'
    };

    Backbone.Form.helpers.setTemplates(templates, classNames);
})();
