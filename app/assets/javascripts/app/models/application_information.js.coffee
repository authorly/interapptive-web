class App.Models.ApplicationInformation extends Backbone.Model
  @contentDescriptionSchema: ->
    schema = {}
    for [category, title] in [
      ['fantasy_violence',         'Cartoon or Fantasy Violence'],
      ['realistic_violence',       'Realistic Violence'],
      ['sexual_content',           'Sexual Content or Nudity'],
      ['profanity',                'Profanity or Crude Humor'],
      ['drugs',                    'Alcohol, Tobacco, or Drug Use or References'],
      ['mature',                   'Mature/Suggestive Themes'],
      ['gambling',                 'Simulated Gambling'],
      ['horror',                   'Horror/Fear Themes'],
      ['prolonged_violence',       'Prolonged Graphic or Sadistic Realistic Violence'],
      ['graphical_sexual_content', 'Graphical Sexual Content and Nudity'],
    ]
      schema[category] =
        type: 'Radio'
        title: title
        options: [
          { val: 'none',    label: 'None' },
          { val: 'mild',    label: 'Infrequent/Mild' },
          { val: 'intense', label: 'Frequent/Intense' },
        ]
    schema

  schema:
    available_from:
      type: 'Date'
      title: "Available from"
      yearStart: (new Date).getFullYear()
      yearEnd: (new Date).getFullYear() + 100
      validators: ['required',
        (value, formValues) ->
          err = {
            type: 'available_from',
            message: 'The application should be available starting on a date in the future'
          }

          now = new Date
          today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
          today = new Date(today.getTime() - today.getTimezoneOffset() * 60 * 1000)
          if value < today then err else null
      ]
    price_tier:
      type: 'Select'
      options: _.map [1..15], (tier) -> val: "tier_#{tier}", label: "$#{tier-1}.99"
      title: "Price tier"
    content_description:
      type: 'Object'
      subSchema: @contentDescriptionSchema()
      title: "Apple Content Descriptions"
    for_kids:
      type: 'Checkbox'
      fieldClass: 'made-for-kids'
      title: 'Made for kids?'
      help: "Made for Kids indicates that your app has been designed for children. These apps will be part of the Kids category on the App Store and will be categorized and searchable by age range. To update existing Privacy Policy URL localizations, see the Metadata and Uploads section on the app’s Version Details page."
    description:
      type: 'TextArea'
      help: "A description of the app you are adding, detailing features and functionality. Descriptions cannot be longer than 4000 characters."
      validators: [
        (value, formValues) ->
          err = {
            type: 'description',
            message: 'Descriptions cannot be longer than 4000 characters.'
          }

          if value.length > 4000 then err else null
      ]
    keywords:
      type: 'Text'
      help: "One or more keywords that describe the app you are adding. When users search the App Store, the terms they enter are matched with keywords to return more accurate results. Separate multiple keywords with commas. Keywords cannot be edited once your binary is in review and cannot be longer than 100 characters."
      validators: [
        (value, formValues) ->
          err = {
            type: 'keywords',
            message: 'Keywords cannot be longer than 100 characters.'
          }

          if value.length > 100 then err else null
      ]
    large_icon_id:
      type: 'Image'
      title: 'Large App Icon'
      help: "A large version of your app icon that will be used on the App Store. It must be at least 72 DPI, in the RGB color space, and 1024 x 1024 pixels (it cannot be scaled up). The file type must be .jpeg, .jpg, .tif, .tiff, or .png. It must be flat artwork without rounded corners."
    retina_3_5_screenshots:
      type: 'List'
      itemType: 'Image'
      title: '3.5-Inch Retina Display Screenshots'
      help: "Screenshots for 3.5-inch iPhone and iPod touch Retina display must be 960x640, 960x600, 640x960 or 640x920 pixels, at least 72 DPI, in the RGB color space, and in the JPG or PNG format."
    retina_4_0_screenshots:
      type: 'List'
      itemType: 'Image'
      title: '4-Inch Retina Display Screenshots'
      help: "Screenshots for 4-inch iPhone 5 and iPod touch (5th generation) Retina display must be 1136x640, 1136x600, 640x1136 or 640x1096 pixels, at least 72 DPI, in the RGB color space, and in the JPG or PNG format."
    retina_ipad_screenshots:
      type: 'List'
      itemType: 'Image'
      title: 'iPad Screenshots'
      help: "iPad Screenshots must be .jpeg, .jpg, .tif, .tiff, or .png file that is 1024x768, 1024x748, 768x1024, 768x1004, 2048x1536, 2048x1496, 1536x2048 or 1536x2008 pixels, at least 72 DPI, and in the RGB color space."


  parse: (attributes={}) ->
    @storybook ||= attributes?.storybook
    delete attributes.storybook

    attributes


  url: ->
    "/storybooks/#{@storybook.id}/application_information.json"


