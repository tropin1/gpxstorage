class @GpxSupport extends @LibSupport
  prepareIndexLists: ->
    super();

    $('[data-type][data-action="remove-dialog"]')
      .data('obj', @)
      .each ->
         $('form:first', @)
            .data('obj', $(@).data('obj'))
            .data('model', $(@).data('type'))
            .on('ajax:error', (xhr, status, error) ->
                alert JSON.stringify(status.responseJSON, null, 2);
                return;
            ).on('ajax:success', (e, result) ->
                obj = $(@).data('obj');
                obj.refreshType $(@).data('model');
                $(@).closest('.modal').modal('hide');
                return;
            );

         return;

    return;

  removeList: (type, items) ->
    dlg = $("[data-type=\"#{type}\"][data-action=\"remove-dialog\"]");
    form = $('form:first', dlg);

    $("textarea[data-type=\"#{type}\"][data-member=\"name_list\"]", form).val ( items.map (x) -> x.name ).join(', ');
    $("input[data-type=\"#{type}\"][data-member=\"ids_list\"]", form).val ( items.map (x) -> x.id ).join(',');

    dlg.modal('show');
    return;

@libSupport = new GpxSupport;

document.addEventListener 'turbolinks:load', ->
  libSupport.prepareIndexLists();
  $('.navbar-fixed-top[role="navigation"]').toggleClass('start-page', $('#overlay').length > 0);

  return;