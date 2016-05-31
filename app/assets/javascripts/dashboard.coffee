class @GpxSupport extends @LibSupport

  listEndReached = ($affected) ->
    url = $affected.data('next_url')
    return if $affected.data('process') || (url || '').length == 0

    $affected.data('process', true)
    $.ajax url,
      type: 'get'
      complete: ( ->
        @removeData('process')
        return
      ).bind($affected)
      error: @showErrorStatus

    return

  checkRemoveButton: (type) ->
    btn = $("[data-type=\"#{type}\"][data-action=\"remove\"]")
    table = @findTable(type)

    btn.toggleClass('active', $('tr td:first-child input[type="checkbox"]:checked', table).length > 0)
    return

  indexList: (type, items_html, paginator_html, clear_body = true) ->
    super(type, items_html, '', clear_body)

    table = @findTable(type).trigger('gpx.list-ready')
    next = table.next()

    next.data('next_url', paginator_html)
    next.appear()
      .data('type', type)
      .attr('data-ready', true)
      .on('appear', (e, $affected) ->
        listEndReached $affected
        return
    ) unless next.is('[data-ready]')

    listEndReached(next) if next.is(':appeared')

    $('.btn-editor:not([data-ready])', table)
      .attr('data-ready', true)
      .click (e) ->
        elem = $(@)
        menu = elem.next()

        onClickDoc = ( ->
          $(@)
            .removeClass('mui--is-open')
            .removeData('close')

          $(document)
            .removeData('ref-item')
            .unbind('click', onClickDoc)

          return
        ).bind(menu)

        if menu.hasClass('mui--is-open')
          onClickDoc()
        else
          cur = $(document).data('ref-item')

          $(document).click() if cur?
          cell = elem.closest('.ref-table-cell,td')

          x = elem.position().left - menu.outerWidth() + elem.outerWidth()
          y = elem.position().top + elem.outerHeight()

          menu
            .css
              position: 'absolute'
              left: x
              top: y
            .addClass('mui--is-open')
            .data('close', onClickDoc)

          $(document)
            .data('ref-item', $(@))

          $(document).click onClickDoc

        false

    return

  prepareIndexLists: ->
    super()

    #$('[data-type][data-action="remove-dialog"]')
    #  .data('obj', @)
    #  .each ->
    #     $('form:first', @)
    #        .data('obj', $(@).data('obj'))
    #        .data('model', $(@).data('type'))
    #        .on('ajax:error', (xhr, status, error) ->
    #            alert JSON.stringify(status.responseJSON, null, 2)
    #            return
    #        ).on('ajax:success', (e, result) ->
    #            obj = $(@).data('obj')
    #            obj.refreshType $(@).data('model')
    #            $(@).closest('.modal').modal('hide')
    #            return
    #        )

    #     return

    #return

  #removeList: (type, items) ->
    #dlg = $("[data-type=\"#{type}\"][data-action=\"remove-dialog\"]")
    #form = $('form:first', dlg)

    #$("textarea[data-type=\"#{type}\"][data-member=\"name_list\"]", form).val ( items.map (x) -> x.name ).join(', ')
    #$("input[data-type=\"#{type}\"][data-member=\"ids_list\"]", form).val ( items.map (x) -> x.id ).join(',')

    #dlg.modal('show')
    #return

@libSupport = new GpxSupport
$side_drawer = undefined

hideSidedrawer = ->
  $('body').toggleClass('hide-sidedrawer')
  return

showSidedrawer = ->
  overlay = $(mui.overlay('on',
    onclose: ->
      $side_drawer.removeClass('active').appendTo(document.body)
      return
  ))

  $side_drawer.appendTo(overlay)
  setTimeout( ( ->
    $side_drawer.addClass('active')
    return
  ), 20);

  return


document.addEventListener 'turbolinks:load', ->
  libSupport.prepareIndexLists()
  $('.navbar-fixed-top[role="navigation"]').toggleClass('start-page', $('#overlay').length > 0)

  $('#search_form').on('submit', ->
    return false unless $('input[type="text"]', @).val().toString().length > 0
  )

  $side_drawer = $('#sidedrawer')
  $('.js-show-sidedrawer').click showSidedrawer
  $('.js-hide-sidedrawer').click hideSidedrawer

  titles = $('#sidedrawer strong');
  titles.next().hide();

  titles.click ->
    $(@).next().slideToggle(200)
    return

  $(window).resize ->
    cur = $(document).data('ref-item')
    $(document).click() if cur?
    return

  return