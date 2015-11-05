setupRenderPreviewButton = (selector) ->
  $(selector).on 'click', (e) ->
    previewArea = $(".preview_area")
    title = $('#article_title').val()
    content = $('#article_content').val()
    $. ajax
      async:     true
      type:      "POST"
      url:       rootPath + "articles/preview"
      dataType:  "html"
      data:
        article:
          title: title
          content: content
      success: (html, status, xhr) ->
        previewArea.empty()
        previewArea.append(html)

ready = ->
  setupRenderPreviewButton('#preview-tab')
  $('.yearly').treeview(
    collapsed: true
    hoverClass: "archive-hover"
  )

$(document).ready(ready)
$(document).on('page:load', ready)
