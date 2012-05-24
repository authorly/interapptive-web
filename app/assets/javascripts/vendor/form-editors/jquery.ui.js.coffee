(->
  Form = Backbone.Form
  Base = Form.editors.Base
  createTemplate = Form.helpers.createTemplate
  triggerCancellableEvent = Form.helpers.triggerCancellableEvent
  exports = {}

  exports.Date = Base.extend(
    className: "bbf-date"
    initialize: (options) ->
      Base::initialize.call this, options
      @value = new Date(@value)  if @value and not _.isDate(@value)
      unless @value
        date = new Date()
        date.setSeconds 0
        date.setMilliseconds 0
        @value = date

    render: ->
      $el = @$el
      $el.html "<input><i class=\"icon-calendar input-icon\"></i></input"
      input = $("input", $el)
      input.addClass "input-small"
      input.datepicker
        dateFormat: "MM, yy"
        showButtonPanel: false

      exports.Date::setValue.call this, @value
      this

    getValue: ->
      input = $("input", @el)
      date = input.datepicker("getDate")
      date

    setValue: (value) ->
      $("input", @el).datepicker "setDate", value
  )

  exports.DateTime = exports.Date.extend(
    className: "bbf-datetime"
    template: createTemplate("<select>{{hours}}</select> : <select>{{mins}}</select>")
    render: ->
      pad = (n) ->
        (if n < 10 then "0" + n else n)
      exports.Date::render.call this
      hours = _.range(0, 24)
      hoursOptions = []
      _.each hours, (hour) ->
        hoursOptions.push "<option value=\"" + hour + "\">" + pad(hour) + "</option>"

      minsInterval = @schema.minsInterval or 15
      mins = _.range(0, 60, minsInterval)
      minsOptions = []
      _.each mins, (min) ->
        minsOptions.push "<option value=\"" + min + "\">" + pad(min) + "</option>"

      @$el.append @template(
        hours: hoursOptions.join()
        mins: minsOptions.join()
      )
      @$hours = $("select:eq(0)", @el)
      @$mins = $("select:eq(1)", @el)
      @setValue @value
      this

    getValue: ->
      input = $("input", @el)
      date = input.datepicker("getDate")
      date.setHours @$hours.val()
      date.setMinutes @$mins.val()
      date.setMilliseconds 0
      date

    setValue: (date) ->
      exports.Date::setValue.call this, date
      @$hours.val date.getHours()
      @$mins.val date.getMinutes()
  )

  exports.List = Base.extend(
    className: "bbf-list"
    template: createTemplate("      <ul></ul>      <div><button class=\"bbf-list-add\">Add</div>    ")
    itemTemplate: createTemplate("      <li rel=\"{{id}}\">        <span class=\"bbf-list-text\">{{text}}</span>        <div class=\"bbf-list-actions\">          <button class=\"bbf-list-edit\">Edit</button>          <button class=\"bbf-list-del\">Delete</button>        </div>      </li>    ")
    editorTemplate: createTemplate("      <div class=\"bbf-field\">          <div class=\"bbf-list-editor\"></div>      </div>    ")
    events:
      "click .bbf-list-add": "addNewItem"
      "click .bbf-list-edit": "editItem"
      "click .bbf-list-del": "deleteItem"

    initialize: (options) ->
      Base::initialize.call this, options
      throw "Missing required option 'schema'"  unless @schema
      @schema.listType = @schema.listType or "Text"
      throw "Missing required option 'schema.model'"  if @schema.listType is "NestedModel" and not @schema.model

    render: ->
      $el = @$el
      $el.html @template()
      self = this
      data = @value or []
      schema = @schema
      itemToString = @itemToString
      itemTemplate = @itemTemplate
      listEl = $("ul", $el)
      _.each data, (itemData) ->
        text = itemToString.call(self, itemData)
        li = $(itemTemplate(
          id: itemData.id or ""
          text: text
        ))
        $.data li[0], "data", itemData
        listEl.append li

      if schema.sortable isnt false
        listEl.sortable
          axis: "y"
          cursor: "move"
          containment: "parent"

        $el.addClass "bbf-list-sortable"
      $("button.bbf-list-add", $el).button
        text: false
        icons:
          primary: "ui-icon-plus"

      $("button.bbf-list-edit", $el).button
        text: false
        icons:
          primary: "ui-icon-pencil"

      $("button.bbf-list-del", $el).button
        text: false
        icons:
          primary: "ui-icon-trash"

      this

    itemToString: (data) ->
      return data  unless data
      schema = @schema
      return schema.itemToString(data)  if schema.itemToString
      if @schema.listType is "NestedModel"
        model = new (@schema.model)(data)
        return model.toString()
      data

    addNewItem: (event) ->
      event.preventDefault()
      self = this
      @openEditor null, (value) ->
        triggerCancellableEvent self, "addItem", [ value ], ->
          text = self.itemToString(value)
          li = $(self.itemTemplate(
            id: value.id or ""
            text: text
          ))
          $.data li[0], "data", value
          $("ul", self.el).append li
          $("button.bbf-list-edit", @el).button
            text: false
            icons:
              primary: "ui-icon-pencil"

          $("button.bbf-list-del", @el).button
            text: false
            icons:
              primary: "ui-icon-trash"

    editItem: (event) ->
      event.preventDefault()
      self = this
      li = $(event.target).closest("li")
      originalValue = $.data(li[0], "data")
      @openEditor originalValue, (newValue) ->
        triggerCancellableEvent self, "editItem", [ newValue ], ->
          $(".bbf-list-text", li).html self.itemToString(newValue)
          $.data li[0], "data", newValue

    deleteItem: (event) ->
      remove = ->
        triggerCancellableEvent self, "removeItem", [ data ], ->
          li.remove()
      event.preventDefault()
      self = this
      li = $(event.target).closest("li")
      data = $.data(li[0], "data")
      confirmDelete = (if (@schema.confirmDelete) then @schema.confirmDelete else false)
      confirmMsg = @schema.confirmDeleteMsg or "Are you sure?"
      if @schema.confirmDelete
        remove()  if confirm(confirmMsg)
      else
        remove()

    openEditor: (data, callback) ->
      self = this
      schema = @schema
      listType = schema.listType or "Text"
      editor = Form.helpers.createEditor(listType,
        key: ""
        schema: schema
        value: data
      ).render()
      container = $(@editorTemplate())
      $(".bbf-list-editor", container).html editor.el
      close = ->
        $(document).unbind "keydown", handleEnterPressed
        container.dialog "close"
        editor.remove()
        container.remove()

      saveAndClose = ->
        errs = editor.validate()
        return  if errs
        callback editor.getValue()
        close()

      handleEnterPressed = (event) ->
        return  unless event.keyCode is 13
        saveAndClose()

      $(container).dialog
        resizable: false
        modal: true
        width: 500
        title: (if data then "Edit item" else "New item")
        buttons:
          OK: saveAndClose
          Cancel: close

      $(document).bind "keydown", handleEnterPressed

    getValue: ->
      data = []
      $("li", @el).each (index, li) ->
        data.push $.data(li, "data")

      data

    setValue: (value) ->
      @value = value
      @render()
  )

  _.extend Form.editors, exports
)()
