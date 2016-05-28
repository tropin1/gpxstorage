class @GpxSupport extends @LibSupport
  indexList: (type, items_html, paginator_html) ->
    super(type, items_html, paginator_html)
    @findTable(type).trigger('gpx.list-ready')

    return;

  prepareIndexLists: ->
    super()

    $('[data-type][data-action="remove-dialog"]')
      .data('obj', @)
      .each ->
         $('form:first', @)
            .data('obj', $(@).data('obj'))
            .data('model', $(@).data('type'))
            .on('ajax:error', (xhr, status, error) ->
                alert JSON.stringify(status.responseJSON, null, 2)
                return
            ).on('ajax:success', (e, result) ->
                obj = $(@).data('obj')
                obj.refreshType $(@).data('model')
                $(@).closest('.modal').modal('hide')
                return
            )

         return

    return

  removeList: (type, items) ->
    dlg = $("[data-type=\"#{type}\"][data-action=\"remove-dialog\"]")
    form = $('form:first', dlg)

    $("textarea[data-type=\"#{type}\"][data-member=\"name_list\"]", form).val ( items.map (x) -> x.name ).join(', ')
    $("input[data-type=\"#{type}\"][data-member=\"ids_list\"]", form).val ( items.map (x) -> x.id ).join(',')

    dlg.modal('show')
    return

@libSupport = new GpxSupport

document.addEventListener 'turbolinks:load', ->
  libSupport.prepareIndexLists()
  $('.navbar-fixed-top[role="navigation"]').toggleClass('start-page', $('#overlay').length > 0)

  $('#search_form').on('submit', ->
    return false unless $('input[type="text"]', @).val().toString().length > 0
  )

  return