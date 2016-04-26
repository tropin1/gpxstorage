class @LibSupport
  checkRemoveButton: (type) ->
    btn = $("[data-type=\"#{type}\"][data-action=\"remove\"]");
    table = @findTable(type);

    btn.attr 'disabled', $('tr td:first-child input[type="checkbox"]:checked', table).length == 0;
    return;

  findTable: (type) ->
    $(".lib-support-list[data-role=\"list\"][data-type=\"#{type}\"]");

  indexList: (type, items_html, paginator_html) ->
    table = @findTable(type);
    paginator = $("[data-type=\"#{type}\"][data-role=\"paginator\"]");

    paginator.html(paginator_html);
    table.find('.mx-selector-th input[type="checkbox"]').prop('checked', false);
    table.find('tbody').html(items_html);

    $('tr td:first-child input[type="checkbox"]', table)
        .data('type', type)
        .data('obj', table.data('obj'))
        .change ->
          obj = $(@).data('obj');
          obj.checkRemoveButton $(@).data('type');
          return;

    $("tr td [data-type=\"#{type}\"][data-action=\"remove_single\"]", table)
      .data('obj', table.data('obj'))
      .click ->
         obj = $(@).data('obj');
         obj.removeList $(@).data('type'), [ { id: $(@).data('id'), name: $(@).closest('tr').find('td:first').next().text() }];
         false;

    @checkRemoveButton(type);
    return;

  prepareIndexLists: ->
    tables = $('.lib-support-list[data-role="list"]');
    tables.data('obj', @);

    tables.each ->
      obj = $(@).data('obj');

      $("[data-type=\"#{$(@).data('type')}\"][data-action=\"remove\"]")
          .data('obj', obj)
          .click ->
            obj = $(@).data('obj');
            table = obj.findTable $(@).data('type');
            ids = ( $('tr td:first-child input[type="checkbox"]:checked', table).map ->
                         {
                           id: $(@).closest('tr').data('id'),
                           name: $(@).closest('tr').find('td:first').next().text()
                         }
            ).toArray();

            obj.removeList $(@).data('type'), ids;
            return;

      obj.refreshTable $(@);
      $('.mx-selector-th input[type="checkbox"]', @)
        .data('type', $(@).data('type'))
        .change ->
          value = $(@).is(':checked');
          table = $(@).closest('.lib-support-list');
          obj = table.data('obj');
          $('tr[data-type][data-id] td:first-child input[type="checkbox"]', table).prop('checked', value);
          obj.checkRemoveButton $(@).data('type');
          return;

      return;

    return;

  refreshTable: (table) ->
    $.ajax "/#{table.data('type-plural')}/index_items",
      type: 'get'
      error: @showErrorStatus;

    return;

  refreshType: (type) ->
    @refreshTable @findTable(type);
    return;

  removeList: (type, items) ->
    alert JSON.stringify(items, null, 2);
    return;

  showErrorStatus: (status) ->
    alert "#{status.status}: #{status.statusText}" unless status.status == 0;
    return;
