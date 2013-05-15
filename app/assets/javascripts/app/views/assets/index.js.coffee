class App.Views.AssetIndex extends Backbone.View
  events:
    'click .delete': 'destroyAsset'

  initialize: ->
    @assetType = @options.assetType # infer from collection type
    @_addListeners()


  remove: ->
    super
    @_removeListeners()


  render: ->
    @table = @$el.dataTable
      aaData:    @_getData()
      aoColumns: @_getColumns()
      aaSorting: [[@_getFields().indexOf('created_at'), 'asc']]
      bLengthChange: false
      oLanguage:
        sEmptyTable: "No #{@assetType}s."



  _addListeners: ->
    @collection.on  'add',    @_assetAdded,   @
    @collection.on  'remove', @_assetRemoved, @


  _removeListeners: ->
    @collection.off 'add',    @_assetAdded,   @
    @collection.off 'remove', @_assetRemoved, @


  _getData: ->
    fields = @_getFields()
    @collection.map (asset) ->
      _.map fields, (field) -> asset.get(field)


  _getColumns: ->
    columns = [
      { sTitle: 'Name' },
      {
        sTitle: 'Size'
        bSearchable: false
        mRender: (data, operation, row) =>
          if operation == 'display'
            App.Lib.NumberHelper.numberToHumanSize(data)
          else
            data
      },
      {
        sTitle: 'Date'
        bSearchable: false
        mRender: (data, operation, row) =>
          if operation == 'display'
            App.Lib.DateTimeHelper.timeToHuman(data)
          else
            data
      }
      {
        sTitle: ''
        bSearchable: false
        bSortable: false
        mRender: (data, operation, row) =>
          if operation == 'display'
            "<button class='delete btn btn-warning' data-id='#{data}'>Delete</button>"
          else
            data
      },
    ]
    if @assetType == 'image'
      columns = [{
        sTitle: ''
        bSearchable: false
        bSortable: false
        mRender: (data, operation, row) =>
          if operation == 'display' && @assetType == 'image'
            "<img src='#{data}'/>"
          else
            data
      }].concat(columns)

    columns


  destroyAsset: (e) =>
    e.preventDefault()
    e.stopPropagation()

    if @assetType == 'image'
      return unless confirm("Are you sure you want to delete this image and corresponding sprites from all the scenes?")

    @_destroyAsset(e)


  _destroyAsset: (e) ->
    id = $(e.currentTarget).data('id')
    asset = @collection.get(id)
    asset.destroy
      url: asset.get('delete_url')


  _assetAdded:  (asset) ->
    data = _.map @_getFields(), (field) -> asset.get(field)
    @table.fnAddData data


  _assetRemoved:  (asset) ->
    id = asset.id
    # TODO add a hidden column just with the ids
    row = @table.find(".delete[data-id=#{id}]").closest('tr')[0]
    @table.fnDeleteRow row


  _getFields: ->
    unless @_fields?
      @_fields = []
      @_fields.push('thumbnail_url') if @assetType == 'image'
      @_fields = @_fields.concat ['name', 'size', 'created_at']
      @_fields.push 'id'
    @_fields

