# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

################################################################
## Text Panel

# Insert TEXT at the cursor point of ELEMENT
#
insertTextAtCaret = (element, text) ->
  pos = element[0].selectionStart
  val = element.val()
  element.val(val.substring(0, pos) + text + val.substring(pos))
  newpos = pos + text.length
  element[0].setSelectionRange(newpos, newpos)

# Insert STRING into Write panel
#
# FIXME: setSelectionRange fails on Firefox
# if target element is not visible. So we have to enable
# the target tab during the manipulation of caret
#
insertToWriterPanel = (string) ->
  current_active_tab = $(".nav-tabs .active a[href]")
  $("a[href='#write']").tab('show')
  textarea = $("#write textarea")
  insertTextAtCaret(textarea, string)
  current_active_tab.tab('show')

# Scroll to ELEM at SPEED
#
$.fn.scrollTo = (elem, speed) ->
  $(this).animate
    scrollTop:  $(this).scrollTop() - $(this).offset().top + $(elem).offset().top
    speed == undefined ? 1000 : speed
  return this;

################################################################
## Picasa
#

getPicasaAlbumCredentials = ->
  res = $. ajax
    async: false
    type: "GET"
    url: "/credentials"
    dataType: "json"
  return res.responseJSON

# Get USER's photo-list in ALBUM as json using AUTHKEY
#
getPicasaAlbum = (user, album, authkey) ->
  top = "https://picasaweb.google.com/data/feed/api"
  $.ajax
    url: "#{top}/user/#{user}/albumid/#{album}"
    async: false
    dataType: 'json'
    data:
      "start-index": 1
      "max-results": 3000
      thumbsize:     '128c'
      kind:          'photo'
      authkey:       authkey
      alt:           'json'
      imgmax:        800
  .responseJSON.feed.entry.map (ent) ->
    id:        ent.gphoto$id.$t
    albumid:   ent.gphoto$albumid.$t
    title:     ent.title.$t
    link:      ent.link[1].href
    published: ent.published.$t
    updated:   ent.updated.$t
    size:      ent.gphoto$size.$t
    src:       ent.content.src
    thumb:     ent.media$group.media$thumbnail[0]
    media:
      content:   ent.media$group.media$content,
      thumbnail: ent.media$group.media$thumbnail
  .sort (a,b) ->
    return -1 if b.updated < a.updated
    return  1 if b.updated > a.updated
    return  0

#
# getPhotoList
#
getPhotoList = (on_success_func) ->
  top = "http://localhost:4567/nomnichi/photos"
  $.ajax
    url: top
    dataType: 'jsonp'
    jsonpCallback: 'pinatra_photo_list'
    data:
      "start-index": 1
      "max-results": 3000
      thumbsize:     '128c'
      kind:          'photo'
      alt:           'json'
      imgmax:        800
    success: (json) ->
      on_success_func(json)
################################################################
# Emoji

insertEmojiPannel = (div) ->
  img_top = "https://assets-cdn.github.com/images/icons/emoji"
  $(div).html window.all_emoji_list.map (e) ->
    """
    <a href="#" data-string=":#{e}:" class="emoji-button">
      <img title="#{e}" src="#{img_top}/#{e}.png" width="32"></img>
    </a>
    """
setupAutoCompleteEmoji = (element) ->
  img_top = "https://assets-cdn.github.com/images/icons/emoji"
  $(element).textcomplete [
      match: /\B:([\-+\w]*)$/

      search: (term, callback) ->
        callback $.map window.all_emoji_list, (emoji) ->
          return emoji if emoji.indexOf(term) != -1
          return null

      template: (value) ->
        "<img src=\"#{img_top}/#{value}.png\" width=\"16\"></img> #{value}"

      replace:  (value) ->
        ":#{value}:"

      index: 1
    ],
    onKeydown: (e, commands) ->
      return commands.KEY_ENTER if e.ctrlKey && e.keyCode == 74 # CTRL-J

################################################################
## Tab action

setupTabCallback = (write, preview) ->
  $('a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
    cur = $(e.target).attr('href')  # newly activated tab
    if $(cur).attr('id') == $(preview).attr('id')
      src = $(write).children('textarea').val()
      renderMarkdown(src, $(cur))
    if $(cur).attr('id') == $(write).attr('id')
      $(write).children('textarea').focus()

################################################################
## Markdown

renderMarkdown = (text, update_element, linenum) ->
  $.post '/articles/preview', {text: text}, (data) ->
    $(update_element).html(data)
    if linenum
      elem = $(update_element).find("[data-linenum='#{linenum}']")[0]
      $(update_element).scrollTo(elem) if elem

################################################################
# original nomnichi pane handler
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

################################################################
## Setup Functions

ready = ->
  setupTabCallback("#write", "#preview")
  # setupAutoCompleteEmoji('#article_content')

  # Insert Emoji Panel
  # insertEmojiPannel('#emoji')

  # click emoji to insert into Write panel
  #$(".emoji-button").on 'click', (ev) ->
  #  insertToWriterPanel $(this).attr('data-string')
  #  ev.preventDefault()

  # Insert Photo panel
  $('#photo').html('<span>Loading...</span>')
  # picasa = getPicasaAlbumCredentials().picasa
  # photo_entries = getPicasaAlbum(picasa.user, picasa.album, picasa.authkey)
  getPhotoList (photo_entries) ->
    $('#photo').html photo_entries.map (entry) ->
      thumb = entry.thumb
      """
      <a class="thumb-link" href="#{entry.src}">
        <img class="thumb" src="#{thumb.url}" width="#{thumb.width}" height="#{thumb.height}" title="#{entry.title}" />
      </a>
      """
    # click photo thumbnail to insert into Write panel
    $('.thumb-link').on 'click', (ev) ->
      insertToWriterPanel "![#{ev.target.title}](#{this.href}){:width=\"300px\" class=\"photo\"}\n"
      ev.preventDefault()

  setupRenderPreviewButton('#preview-tab')
  $('.yearly').treeview(
    collapsed: true
    hoverClass: "archive-hover"
  )

$(document).ready(ready)
$(document).on('page:load', ready)
