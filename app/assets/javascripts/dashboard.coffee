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

  removeList: (type, items) ->
    dlg = $(".modal[data-action=\"remove-dialog\"][data-type=\"#{type}\"]")

    dlg.find('*').removeAttr('id').removeClass('mx-invalid-value')
    $('.mx-error-help-block', dlg).remove()

    dlg = dlg.clone().show()
    $('a[data-action="close"]', dlg).click ->
      mui.overlay 'off'
      false

    $('form:first', dlg)
      .data('obj', @)
      .data('model', type)
      .on('ajax:error', (xhr, status, error) ->
        model = $(@).data('model')

        $('.mx-error-help-block', @).remove()
        $('[data-member]').removeClass('mx-invalid-value')

        $.each(status.responseJSON, (k, v) ->
          $("[name=\"#{model}[#{k}]\"]")
            .addClass('mx-invalid-value')
            .after("<small class=\"mx-error-help-block\">#{v}</small>")

          return
        )

        return
    ).on('ajax:success', (e, result) ->
        obj = $(@).data('obj')
        obj.refreshType $(@).data('model')
        mui.overlay 'off'

        return
    )

    $("textarea[data-type=\"#{type}\"][data-member=\"name_list\"]", dlg).val (items.map (x) -> x.name).join(', ')
    $("input[data-type=\"#{type}\"][data-member=\"ids_list\"]", dlg).val (items.map (x) -> x.id).join(',')

    mui.overlay 'on', dlg[0] unless dlg.length == 0
    return

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

  $('#sidedrawer strong').click ->
    $(@).next().slideToggle(200)
    return

  $(window).resize ->
    cur = $(document).data('ref-item')
    $(document).click() if cur?
    return

  $('.btn-search-show').click ->
    bar = $(@).closest('.search-bar')
    bar.addClass('active')
    bar.find('input:first').focus().select()

    false

  $('.btn-search-hide').click ->
    bar = $(@).closest('.search-bar')
    input = bar.find('input:first')
    input.val('').trigger('keyup') if $.trim(input.val()).length > 0

    bar.removeClass('active')
    false

  return