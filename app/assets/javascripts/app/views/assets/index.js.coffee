##
# A view that displays a collection of assets as a table.
# It allows sorting and searching through the collection.
#
class App.Views.AssetIndex extends Backbone.View
  events:
    'click .delete': 'destroyAsset'

  initialize: ->
    @assetType = @options.assetType # infer from collection type
    @allowDelete = @options.allowDelete
    @defaultAsset = @options.default
    @_addListeners()


  remove: ->
    @_removeListeners()
    super


  render: ->
    models = if @defaultAsset? then [@defaultAsset] else []
    models = models.concat(@collection.models)
    data = _.map models, @_getData
    @table = @$el.dataTable
      aaData: data
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


  _getData: (asset) =>
    fields = @_getFields()
    row = DT_RowId: 'asset_' + asset.id
    _.each fields, (field, index) ->
      row[index] = asset.get(field) || null
    row


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
            if data?
              App.Lib.DateTimeHelper.timeToHuman(data)
            else
              ''
          else
            data
      }
    ]

    if @allowDelete
      columns.push
        sTitle: ''
        bSearchable: false
        bSortable: false
        mRender: (data, operation, row) =>
          if operation == 'display'
            "<button class='delete btn btn-warning'>Delete</button>"
          else
            data

    if @assetType == 'image'
      columns = [{
        sTitle: ''
        bSearchable: false
        bSortable: false
        mRender: (data, operation, row) =>
          if operation == 'display' && @assetType == 'image'
            "<img src='#{data}' class='preview'/>"
          else
            data
      }].concat(columns)

    columns


  getId: (row) ->
    id = row.attr('id') # asset_<id>
    id.substr(id.indexOf('_') + 1)


  # Corresponding widgets are destroyed when an asset is destroyed.
  # Look for imageRemoved, soundRemoved and other functions under
  # App.Collections.Widgets
  destroyAsset: (e) =>
    e.preventDefault()
    e.stopPropagation()

    if @assetType isnt 'font'
      return unless confirm("Are you sure you want to delete this #{@assetType} and corresponding #{@_assetTypeToWidgetType()} from all the scenes?")

    @_destroyAsset(e)


  _assetTypeToWidgetType: ->
    switch @assetType
      when 'image' then 'sprites'
      when 'sound' then 'hotspots'
      when 'video' then 'hotspots'
      when 'font'  then 'texts'


  _destroyAsset: (e) ->
    row = $(e.currentTarget).closest('tr')
    id = @getId(row)
    asset = @collection.get(id)
    asset.destroy
      url: asset.get('delete_url')


  _assetAdded:  (asset) ->
    data = @_getData(asset)
    @table.fnAddData data


  _assetRemoved:  (asset) ->
    id = asset.id
    # TODO add a hidden column just with the ids
    row = @table.find("tr#asset_#{id}")[0]
    @table.fnDeleteRow row


  _getFields: ->
    unless @_fields?
      @_fields = []
      @_fields.push('thumbnail_url') if @assetType == 'image'
      @_fields = @_fields.concat ['name', 'size', 'created_at']
      @_fields.push('id') if @allowDelete
    @_fields

