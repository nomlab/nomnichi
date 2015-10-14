setupRenderPreviewButton = (selector) ->
  $(selector).on 'click', (e) ->
    previewArea = $(".preview_area")
    title = $('#article_title').val()
    content = $('#article_content').val()
    $. ajax
      async:     true
      type:      "POST"
      url:       "/articles/preview"
      dataType:  "html"
      data:
        article:
          content: content
      success: (html, status, xhr) ->
        previewArea.empty()
        previewArea.append(html)

ready = ->
  setupRenderPreviewButton('#preview')
  $('.yearly').treeview(
    collapsed: true
  )

$(document).ready(ready)
$(document).on('page:load', ready)
