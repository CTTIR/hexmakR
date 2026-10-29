# The editor starts with a new project; archived designs are optional sources.
.cttir_new_design <- function() logo_design("New project")

.cttir_part_choices <- function(design) {
  parts <- hex_layers(design)
  label <- if ("name" %in% names(parts)) parts$name else parts$type
  stats::setNames(parts$id, paste(label, parts$type, parts$id, sep = " \u00b7 "))
}

.cttir_editor_ui <- function(package) {
  initial <- .cttir_new_design()
  icons <- unlist(lapply(.icons, function(group) stats::setNames(
    names(group), vapply(group, `[[`, character(1), "label"))), use.names = TRUE)
  shiny::tagList(
    shiny::div(class = "row editor-row",
      shiny::column(4, shiny::div(class = "editor-controls",
        shiny::h3("Create a logo"),
        shiny::textInput("label", "Package or project name", initial$label),
        shiny::selectInput("shape", "Frame", c("Hexagon" = "hex",
          "Pentagon" = "pentagon", "Square" = "square")),
        shiny::fluidRow(
          shiny::column(6, shiny::selectInput("mode", "Appearance",
            c("Dark" = "dark", "Light" = "light", "Monochrome" = "mono"))),
          shiny::column(6, shiny::selectInput("layout", "Composition",
            c("Name inside frame" = "lockup", "Artwork only" = "hex",
              "No frame" = "motif")))
        ),
        shiny::selectizeInput("generic_icon", "Base artwork",
          choices = c("Blank canvas" = "blank", "Keep current artwork" = "keep", icons),
          selected = "blank"),
        shiny::tags$details(shiny::tags$summary("Palette and layout"),
          shiny::selectInput("role", "Colour role", names(hex_palette(initial))),
          shiny::textInput("role_color", "Colour (name or hex)", "#193F34"),
          shiny::actionButton("apply_color", "Set colour"),
          shiny::actionButton("reset_colors", "Restore palette"),
          shiny::sliderInput("motif_x", "Base artwork horizontal position", 0, 1, .5, step = .01),
          shiny::sliderInput("motif_y", "Base artwork vertical position", 0, 1, .585, step = .005),
          shiny::sliderInput("motif_scale", "Base artwork size", .1, 2, 1, step = .01),
          shiny::sliderInput("label_y", "Name vertical position", 0, 1, .215, step = .005),
          shiny::sliderInput("label_size", "Name size", 6, 64, 32, step = .5),
          shiny::sliderInput("border_width", "Border width", 0, 20, 5.5, step = .5)
        ),
        shiny::actionButton("apply_design", "Apply logo settings", class = "btn-primary"),
        shiny::tags$hr(), shiny::h3("Add and edit parts"),
        shiny::fluidRow(
          shiny::column(7, shiny::selectInput("part_type", "New part",
            c("Circle" = "circle", "Rectangle" = "rectangle",
              "Line" = "line", "Triangle" = "polygon"))),
          shiny::column(5, shiny::actionButton("add_part", "Add part"))
        ),
        shiny::fileInput("art_upload", "Add an image or vector drawing",
          accept = c(".png", ".jpg", ".jpeg", ".svg")),
        shiny::helpText("PNG/JPEG: one image part. SVG: editable solid-colour shapes, paths and local references. Maximum 10 MiB; existing work is kept."),
        shiny::tags$details(shiny::tags$summary("Preparing an SVG"),
          shiny::p("Outline text; flatten gradients, masks, filters and intersecting clips first. Curves become vector polylines.")),
        shiny::selectizeInput("layer", "Selected part", choices = NULL),
        shiny::textInput("part_label", "Short name", ""),
        shiny::actionButton("rename_part", "Rename part"),
        shiny::textOutput("part_detail"),
        shiny::radioButtons("mouse_target", "Mouse target",
          c("Individual part" = "part", "Whole group" = "group"), inline = TRUE),
        shiny::tags$details(shiny::tags$summary("Image groups"),
          shiny::selectInput("group", "Group", choices = NULL),
          shiny::textInput("group_label", "Group name", ""),
          shiny::selectizeInput("group_members", "Group members", choices = NULL, multiple = TRUE),
          shiny::actionButton("create_group", "Create group"),
          shiny::actionButton("update_group", "Set members"),
          shiny::actionButton("rename_group", "Rename group"),
          shiny::actionButton("ungroup_parts", "Ungroup selected members"),
          shiny::fluidRow(
            shiny::column(6, shiny::numericInput("group_dx", "Move group horizontally", 0, -1, 1, .01)),
            shiny::column(6, shiny::numericInput("group_dy", "Move group vertically", 0, -1, 1, .01))),
          shiny::actionButton("move_group", "Move group"),
          shiny::helpText("Whole group mode moves all members together when dragging. The part controls below edit the selected member.")),
        shiny::checkboxInput("highlight", "Highlight selected part", FALSE),
        shiny::fluidRow(
          shiny::column(6, shiny::textInput("fill", "Fill (blank keeps original)", "")),
          shiny::column(6, shiny::textInput("stroke", "Outline (blank keeps original)", ""))
        ),
        shiny::fluidRow(
          shiny::column(6, shiny::numericInput("dx", "Horizontal offset", 0, -100, 100, .01)),
          shiny::column(6, shiny::numericInput("dy", "Vertical offset", 0, -100, 100, .01))
        ),
        shiny::fluidRow(
          shiny::column(6, shiny::numericInput("scale", "Part size", 1, .1, 3, .05)),
          shiny::column(6, shiny::numericInput("lwd", "Outline width", 1, 0, 1000, .5))
        ),
        shiny::sliderInput("angle", "Rotation (degrees)", -180, 180, 0, step = 1),
        shiny::sliderInput("alpha", "Opacity", 0, 1, 1, step = .05),
        shiny::checkboxInput("visible", "Visible", TRUE),
        shiny::tags$details(shiny::tags$summary("Edit points"),
          shiny::helpText("Move individual points using their local coordinates. Keep the same number of points; blank fields keep the original geometry."),
          shiny::actionButton("load_points", "Load original points"),
          shiny::textAreaInput("coords_x", "X coordinates (comma separated)", "", rows = 3),
          shiny::textAreaInput("coords_y", "Y coordinates (comma separated)", "", rows = 3)),
        shiny::actionButton("apply_layer", "Apply part edit", class = "btn-primary"),
        shiny::actionButton("reset_layer", "Restore part"),
        shiny::actionButton("duplicate_part", "Duplicate part"),
        shiny::actionButton("remove_part", "Remove part"),
        shiny::tags$hr(),
        shiny::actionButton("undo", "Undo"),
        shiny::actionButton("reset", "Reset to starting design"),
        shiny::actionButton("new_project", "New logo"),
        shiny::fileInput("project", "Open saved project", accept = ".json")
      )),
      shiny::column(8,
        shiny::div(class = "preview-card",
          shiny::div(class = "preview-heading",
            shiny::h2(shiny::textOutput("design_title", inline = TRUE)),
            shiny::textOutput("design_detail")),
          shiny::uiOutput("error"),
          shiny::div(id = "preview-stage", class = "checkerboard",
            shiny::imageOutput("preview", height = "570px",
              click = shiny::clickOpts(id = "preview_click", clip = TRUE)),
            shiny::uiOutput("selection_overlay", class = "preview-selection")),
          shiny::helpText("Click to select a part. Drag and release to move it. Use the part list for overlapping or hidden items."),
          shiny::tags$p(class = "preview-caption",
            "Your editable logo \u00b7 Transparent exterior \u00b7 Undo available"),
          shiny::fluidRow(
            shiny::column(4, shiny::numericInput("export_width", "PNG width (pixels)", 1600, 32, 8192, 100)),
            shiny::column(8, shiny::div(class = "export-actions",
              shiny::downloadButton("png", "PNG"), shiny::downloadButton("svg", "SVG"),
              shiny::downloadButton("pdf", "PDF"), shiny::downloadButton("json", "Save project"),
              shiny::downloadButton("recipe", "R recipe"))))
        ),
        shiny::tags$p(class = "help-note",
          "Start with your own name and frame, then add and edit individual parts. The CTTIR Gallery offers optional inspiration and reusable artwork; browsing it leaves your logo unchanged.")
      )
    )
  )
}

.cttir_archive_ui <- function(package, cards) {
  shiny::tagList(
    shiny::h2("CTTIR Gallery"),
    shiny::p("Browse the existing designs for inspiration, or reuse their artwork in your logo."),
    shiny::div(class = "preview-card", shiny::fluidRow(
      shiny::column(5,
        shiny::selectizeInput("identity", "Gallery design", hex_catalog()$name, selected = package),
        shiny::selectizeInput("archive_layer", "Part to reuse", choices = NULL),
        shiny::actionButton("archive_add_part", "Add selected part to my logo", class = "btn-primary"),
        shiny::actionButton("archive_add_motif", "Add artwork to my logo"),
        shiny::tags$hr(),
        shiny::actionButton("archive_load", "Start from whole design"),
        shiny::helpText("Adding artwork keeps your name, frame and existing parts. Starting from the whole design replaces the logo; Undo restores the previous version.")),
      shiny::column(7, shiny::imageOutput("archive_preview", height = "320px"))
    )),
    shiny::div(class = "gallery-grid", cards)
  )
}

# Slider updates go through this binding so tests can replace it.
.update_slider <- function(session, inputId, value) shiny::updateSliderInput(session, inputId, value = value)

.cttir_editor_server <- function(input, output, session, package = "hexmakR") {
  initial <- .cttir_new_design()
  current <- shiny::reactiveVal(initial)
  baseline <- shiny::reactiveVal(initial)
  history <- shiny::reactiveVal(list())
  selection <- shiny::reactiveVal(NULL)
  group_selection <- shiny::reactiveVal(NULL)
  show_selection <- shiny::reactiveVal(FALSE)
  render_sequence <- 0L
  preview_revision <- shiny::reactive({
    current()
    render_sequence <<- render_sequence + 1L
    paste0("preview-", render_sequence)
  })
  hit_map <- shiny::reactive(.hex_hit_map(current(), width = 800))
  error <- shiny::reactiveVal(NULL)
  commit <- function(d, selected = NULL, start = FALSE) {
    .validate_design(d); hex_grob(d)
    if (!identical(d, current()) || isTRUE(start)) {
      previous <- list(design = current(), baseline = baseline())
      history(utils::tail(c(history(), list(previous)), 30L))
      if (isTRUE(start)) baseline(d)
      if (!is.null(selected)) selection(selected)
      current(d)
    }
    error(NULL)
    invisible(d)
  }
  attempt <- function(expr) tryCatch(force(expr), error = function(e) error(conditionMessage(e)))
  sync_controls <- function(d) {
    shiny::updateSelectInput(session, "mode", selected = d$mode)
    shiny::updateSelectInput(session, "layout", selected = d$layout)
    shiny::updateSelectInput(session, "shape", selected = d$shape)
    icon <- if (nzchar(d$icon)) d$icon else if (isTRUE(d$archive)) "keep" else "blank"
    shiny::updateSelectizeInput(session, "generic_icon", selected = icon)
    shiny::updateTextInput(session, "label", value = d$label)
    for (id in c("motif_x", "motif_y", "motif_scale", "label_y", "label_size", "border_width"))
      .update_slider(session, id, value = d[[id]])
  }
  archive_design <- shiny::reactive(hex_design(input$identity %||% package))
  shiny::observeEvent(archive_design(), {
    choices <- .cttir_part_choices(archive_design())
    parts <- hex_layers(archive_design())
    motif <- if ("role" %in% names(parts)) parts$id[parts$role == "motif"] else parts$id
    selected <- if (length(motif)) motif[[1]] else parts$id[[1]]
    shiny::updateSelectizeInput(session, "archive_layer", choices = choices, selected = selected)
  })
  shiny::observeEvent(input$layout, {
    if (!identical(input$layout, current()$layout))
      .update_slider(session, "motif_y", value = if (input$layout == "lockup") .585 else .5)
  }, ignoreInit = TRUE)
  shiny::observeEvent(input$apply_design, attempt({
    old <- current()
    value <- function(id) input[[id]] %||% old[[id]]
    artwork <- input$generic_icon %||% "keep"
    icon <- if (artwork == "keep") old$icon else if (artwork == "blank") "" else artwork
    archive <- if (artwork == "keep") old$archive else FALSE
    d <- hex_design(old$package, value("mode"), value("layout"), value("label"), old$colors,
      value("motif_x"), value("motif_y"), value("motif_scale"), value("label_y"),
      value("label_size"), value("border_width"), shape = value("shape"), icon = icon,
      archive = archive)
    d$parts <- old$parts
    if (identical(d$layout, old$layout) && identical(d$icon, old$icon) &&
        identical(d$archive, old$archive) && identical(d$shape, old$shape) &&
        identical(nzchar(d$label), nzchar(old$label))) {
      d$layers <- old$layers
      if (!identical(d$label, old$label)) {
        native <- hex_layers(old)
        name_ids <- native$id[native$role == "name"]
        for (id in intersect(name_ids, names(d$layers))) {
          d$layers[[id]]$x <- NULL
          d$layers[[id]]$y <- NULL
        }
      }
    } else {
      d$layers <- old$layers[grepl("^part_", names(old$layers))]
    }
    d <- .cttir_transfer_metadata(old, d)
    commit(d)
  }))
  shiny::observeEvent(list(current(), input$role), {
    shiny::req(input$role)
    shiny::updateTextInput(session, "role_color", value = hex_palette(current())[[input$role]])
  })
  shiny::observeEvent(input$apply_color, attempt({
    shiny::req(input$role)
    d <- current(); d$colors[[input$role]] <- input$role_color; commit(d)
  }))
  shiny::observeEvent(input$reset_colors, attempt({ d <- current(); d$colors <- list(); commit(d) }))
  shiny::observeEvent(input$layer, {
    if (length(input$layer) == 1L && input$layer %in% hex_layers(current())$id)
      selection(input$layer)
  })
  shiny::observeEvent(input$highlight, { show_selection(isTRUE(input$highlight)) })
  shiny::observeEvent(current(), {
    choices <- .cttir_part_choices(current())
    selected <- shiny::isolate(selection())
    if (!length(choices)) {
      selection(NULL)
      shiny::updateSelectizeInput(session, "layer", choices = character(), selected = character())
      return(invisible(NULL))
    }
    if (is.null(selected) || !selected %in% choices) selected <- unname(choices[[1]])
    selection(selected)
    shiny::updateSelectizeInput(session, "layer", choices = choices, selected = selected)
  })
  shiny::observeEvent(list(selection(), current()), {
    id <- selection()
    shiny::req(id)
    g <- hex_grob(current())$children[[id]]
    shiny::req(!is.null(g))
    g <- .layer_leaf(g)
    e <- current()$layers[[id]] %||% list()
    parts <- hex_layers(current())
    shiny::updateTextInput(session, "part_label", value = parts$name[match(id, parts$id)])
    for (key in c("fill", "stroke")) {
      value <- e[[if (key == "stroke") "col" else key]] %||% ""
      shiny::updateTextInput(session, key, value = value)
    }
    for (key in c("dx", "dy", "scale", "lwd")) shiny::updateNumericInput(session, key,
      value = e[[key]] %||% switch(key, dx = 0, dy = 0, scale = 1, lwd = g$gp$lwd %||% 1))
    .update_slider(session, "angle", value = e$angle %||% 0)
    .update_slider(session, "alpha",
      value = .cttir_part_alpha(current(), id, g, e))
    shiny::updateCheckboxInput(session, "visible", value = e$visible %||% TRUE)
    for (axis in c("x", "y")) shiny::updateTextAreaInput(session, paste0("coords_", axis),
      value = if (is.null(e[[axis]])) "" else paste(e[[axis]], collapse = ", "))
  })
  shiny::observeEvent(input$load_points, attempt({
    id <- selection(); shiny::req(id)
    d <- current(); d$layers <- list()
    g <- .layer_leaf(hex_grob(d)$children[[id]])
    for (axis in c("x", "y")) shiny::updateTextAreaInput(session, paste0("coords_", axis),
      value = if (is.null(g[[axis]])) "" else paste(signif(as.numeric(g[[axis]]), 8), collapse = ", "))
  }))
  shiny::observeEvent(input$apply_layer, attempt({
    id <- selection(); shiny::req(id)
    edits <- list(dx = input$dx, dy = input$dy, scale = input$scale, lwd = input$lwd,
      angle = input$angle, alpha = input$alpha, visible = input$visible)
    edits <- edits[!vapply(edits, is.null, logical(1))]
    if (nzchar(input$fill %||% "")) edits$fill <- input$fill
    if (nzchar(input$stroke %||% "")) edits$col <- input$stroke
    for (axis in c("x", "y")) {
      value <- input[[paste0("coords_", axis)]] %||% ""
      if (nzchar(trimws(value))) edits[[axis]] <- suppressWarnings(as.numeric(strsplit(value, "[,[:space:]]+")[[1]]))
    }
    commit(do.call(hex_edit_layer, c(list(design = current(), layer = id, reset = TRUE), edits)))
  }))
  shiny::observeEvent(input$reset_layer, attempt(commit(hex_edit_layer(current(), selection(), reset = TRUE))))
  add_design <- function(d) {
    added <- setdiff(hex_layers(d)$id, hex_layers(current())$id)
    commit(d, if (length(added)) added[[length(added)]] else NULL)
    shiny::updateTabsetPanel(session, "workspace", selected = "designer")
  }
  shiny::observeEvent(input$art_upload, attempt({
    add_design(.cttir_uploaded_art(current(), input$art_upload))
  }))
  shiny::observeEvent(input$rename_part, attempt({
    id <- selection(); shiny::req(id)
    commit(hex_label_layer(current(), id, input$part_label), selected = id)
  }))
  shiny::observeEvent(input$add_part, attempt({
    add_design(hex_add_part(current(), type = input$part_type %||% "circle"))
  }))
  shiny::observeEvent(input$duplicate_part, attempt({
    id <- selection(); shiny::req(id)
    add_design(hex_duplicate_part(current(), id))
  }))
  shiny::observeEvent(input$remove_part, attempt({
    id <- selection(); shiny::req(id)
    commit(hex_remove_part(current(), id))
  }))
  shiny::observeEvent(input$archive_add_part, attempt({
    shiny::req(input$archive_layer)
    add_design(hex_reuse_part(current(), archive_design(), input$archive_layer))
  }))
  shiny::observeEvent(input$archive_add_motif, attempt({
    add_design(hex_reuse_part(current(), archive_design()))
  }))
  shiny::observeEvent(input$archive_load, attempt({
    d <- archive_design(); commit(d, start = TRUE); sync_controls(d)
    shiny::updateTabsetPanel(session, "workspace", selected = "designer")
  }))
  shiny::observeEvent(input$undo, {
    h <- history()
    if (length(h)) {
      previous <- h[[length(h)]]; history(h[-length(h)])
      baseline(previous$baseline); current(previous$design)
      sync_controls(previous$design); error(NULL)
    }
  })
  shiny::observeEvent(input$reset, attempt({
    d <- baseline(); commit(d); sync_controls(d)
  }))
  shiny::observeEvent(input$new_project, attempt({
    d <- .cttir_new_design(); commit(d, start = TRUE); sync_controls(d)
  }))
  shiny::observeEvent(input$project, attempt({
    d <- hex_read_design(input$project$datapath); commit(d, start = TRUE); sync_controls(d)
  }))
  for (name in hex_catalog()$name) local({
    identity <- name
    shiny::observeEvent(input[[paste0("pick_", identity)]], {
      shiny::updateSelectizeInput(session, "identity", selected = identity)
      shiny::updateTabsetPanel(session, "workspace", selected = "gallery")
    })
  })
  groups <- shiny::reactive(hex_groups(current()))
  shiny::observeEvent(input$group, {
    if (length(input$group) == 1L && input$group %in% names(groups())) group_selection(input$group)
  })
  shiny::observeEvent(current(), {
    available <- groups()
    selected <- shiny::isolate(group_selection())
    if (is.null(selected) || !selected %in% names(available))
      selected <- if (length(available)) names(available)[[1]] else NULL
    group_selection(selected)
    choices <- vapply(available, `[[`, character(1), "label")
    shiny::updateSelectInput(session, "group",
      choices = stats::setNames(names(choices) %||% character(), choices), selected = selected %||% character())
    shiny::updateSelectizeInput(session, "group_members",
      choices = .cttir_part_choices(current()), selected = available[[selected %||% ""]]$members %||% character())
  })
  shiny::observeEvent(list(group_selection(), current()), {
    group <- groups()[[group_selection() %||% ""]]
    shiny::updateTextInput(session, "group_label", value = group$label %||% "New group")
    shiny::updateSelectizeInput(session, "group_members", selected = group$members %||% character())
  })
  shiny::observeEvent(input$create_group, attempt({
    before <- names(groups())
    d <- hex_group_layers(current(), input$group_members, input$group_label)
    id <- setdiff(names(hex_groups(d)), before)
    if (length(id)) group_selection(id[[length(id)]])
    commit(d)
  }))
  shiny::observeEvent(input$update_group, attempt({
    shiny::req(group_selection())
    commit(hex_group_layers(current(), input$group_members, input$group_label,
      group = group_selection()))
  }))
  shiny::observeEvent(input$rename_group, attempt({
    shiny::req(group_selection())
    commit(hex_rename_group(current(), group_selection(), input$group_label))
  }))
  shiny::observeEvent(input$ungroup_parts, attempt({
    commit(hex_ungroup_layers(current(), input$group_members))
  }))
  shiny::observeEvent(input$move_group, attempt({
    group <- groups()[[group_selection() %||% ""]]
    shiny::req(group)
    commit(.hex_translate_layers(current(), group$members,
      input$group_dx %||% 0, input$group_dy %||% 0))
    shiny::updateNumericInput(session, "group_dx", value = 0)
    shiny::updateNumericInput(session, "group_dy", value = 0)
  }))
  select_hit <- function(id) {
    selection(id)
    shiny::updateSelectizeInput(session, "layer", selected = id)
    if (identical(input$mouse_target, "group")) {
      memberships <- names(groups())[vapply(groups(), function(g) id %in% g$members, logical(1))]
      selected <- if (length(memberships)) memberships[[1]] else NULL
      group_selection(selected)
      shiny::updateSelectInput(session, "group", selected = selected %||% character())
    }
    show_selection(TRUE)
    shiny::updateCheckboxInput(session, "highlight", value = TRUE)
  }
  valid_revision <- function(event) {
    is.null(event$render_id) || identical(event$render_id, preview_revision())
  }
  shiny::observeEvent(input$preview_click, attempt({
    event <- input$preview_click
    if (!valid_revision(event)) return(invisible(NULL))
    map <- hit_map()
    point <- .cttir_preview_point(event, map$width, map$height)
    if (is.null(point)) return(invisible(NULL))
    id <- .hex_hit_test(map, point$x, point$y)
    if (!is.null(id)) select_hit(id)
  }))
  shiny::observeEvent(input$preview_drag, attempt({
    event <- input$preview_drag
    if (!valid_revision(event)) return(invisible(NULL))
    map <- hit_map()
    start <- .cttir_preview_point(event$start, map$width, map$height)
    end <- .cttir_preview_point(event$end, map$width, map$height)
    if (is.null(start) || is.null(end)) return(invisible(NULL))
    id <- .hex_hit_test(map, start$x, start$y)
    if (is.null(id)) return(invisible(NULL))
    select_hit(id)
    ids <- id
    if (identical(input$mouse_target, "group")) {
      group <- groups()[[group_selection() %||% ""]]
      if (!is.null(group)) ids <- group$members
    }
    commit(.hex_translate_layers(current(), ids, end$x - start$x, end$y - start$y), selected = id)
  }))
  output$design_title <- shiny::renderText(if (nzchar(current()$label)) current()$label else "Untitled logo")
  output$design_detail <- shiny::renderText(paste(current()$mode, current()$shape,
    paste(nrow(hex_layers(current())), "editable parts"), sep = " / "))
  output$part_detail <- shiny::renderText({
    id <- selection()
    parts <- hex_layers(current())
    row <- parts[parts$id == id, , drop = FALSE]
    if (nrow(row)) paste(row$type, row$points, "points") else "Select a part to edit."
  })
  output$error <- shiny::renderUI({
    if (!is.null(error())) shiny::div(class = "alert alert-danger", role = "alert", error())
  })
  preview_image <- function(d, alt) {
    path <- tempfile(fileext = ".png")
    hex_export(d, path, width = 800)
    list(src = path, contentType = "image/png", alt = alt)
  }
  output$preview <- shiny::renderImage({
    d <- current()
    width <- 800L; height <- round(width / .design_ratio(d))
    revision <- preview_revision()
    image <- preview_image(d, paste(d$label, "design preview; click or drag a part"))
    image$coordmap <- .cttir_preview_coordmap(width, height, revision)
    image[["data-render-id"]] <- revision
    image$draggable <- "false"
    image
  }, deleteFile = TRUE)
  output$selection_overlay <- shiny::renderUI({
    shiny::req(isTRUE(show_selection()))
    ids <- selection()
    if (identical(input$mouse_target, "group")) {
      group <- hex_groups(current())[[group_selection() %||% ""]]
      if (!is.null(group)) ids <- group$members
    }
    map <- hit_map()
    boxes <- Filter(Negate(is.null), lapply(ids, function(id) .hex_hit_bounds(map, id)))
    if (!length(boxes)) return(NULL)
    x0 <- min(vapply(boxes, `[[`, numeric(1), "xmin"))
    x1 <- max(vapply(boxes, `[[`, numeric(1), "xmax"))
    y0 <- min(vapply(boxes, `[[`, numeric(1), "ymin"))
    y1 <- max(vapply(boxes, `[[`, numeric(1), "ymax"))
    shiny::tags$svg(viewBox = "0 0 1 1", preserveAspectRatio = "none",
      `aria-hidden` = "true", shiny::tags$rect(x = x0, y = 1 - y1,
        width = x1 - x0, height = y1 - y0, fill = "none", stroke = "#D81B60",
        `stroke-width` = 3, `vector-effect` = "non-scaling-stroke"))
  })
  output$archive_preview <- shiny::renderImage({
    d <- archive_design()
    if (!is.null(input$archive_layer) && input$archive_layer %in% hex_layers(d)$id)
      d <- hex_edit_layer(d, input$archive_layer, col = "#FF4081", lwd = 4)
    preview_image(d, paste(d$package, "gallery preview"))
  }, deleteFile = TRUE)
  stem <- shiny::reactive({
    name <- if (nzchar(current()$label)) current()$label else "logo"
    name <- gsub("[^A-Za-z0-9._-]+", "-", name)
    paste(name, current()$shape, current()$layout, current()$mode, sep = "-")
  })
  for (ext in c("png", "svg", "pdf")) local({
    format <- ext
    output[[format]] <- shiny::downloadHandler(filename = function() paste0(stem(), ".", format),
      content = function(file) {
        temp <- tempfile(fileext = paste0(".", format)); on.exit(unlink(temp), add = TRUE)
        hex_export(current(), temp, width = input$export_width %||% 1600)
        if (!file.copy(temp, file, overwrite = TRUE)) stop("Could not write export.")
      }, contentType = switch(format, png = "image/png", svg = "image/svg+xml", pdf = "application/pdf"))
  })
  output$json <- shiny::downloadHandler(filename = function() paste0(stem(), ".json"),
    content = function(file) hex_save_design(current(), file), contentType = "application/json")
  output$recipe <- shiny::downloadHandler(filename = function() paste0(stem(), ".R"),
    content = function(file) hex_recipe(current(), file), contentType = "text/plain")
  invisible(list(current = current, history = history, error = error))
}

.build_shiny_app <- function(package = "hexmakR") {
  .identity_row(package)
  shiny::addResourcePath("hexmakr-v5", .cttir_masters())
  registry <- hex_catalog()
  cards <- lapply(seq_len(nrow(registry)), function(i) {
    row <- registry[i, ]
    shiny::div(class = "gallery-card", `data-family` = row$family,
      shiny::tags$img(src = paste0("hexmakr-v5/", row$asset_dir, "/lockup-dark.svg"), alt = row$name, loading = "lazy"),
      shiny::h4(row$name), shiny::tags$p(paste(row$family, row$kind, sep = " \u00b7 ")),
      shiny::actionButton(paste0("pick_", row$name), "Inspect parts"),
      shiny::tags$a(href = paste0("hexmakr-v5/", row$asset_dir, "/lockup-dark.svg"), download = paste0(row$name, ".svg"), "Original SVG"))
  })
  css <- "
    body{background:#f2f4f6;color:#1b2b37;font-family:system-ui,sans-serif}
    .navbar{border:0;border-radius:0;background:#173c36}.navbar-default .navbar-brand,.navbar-default .navbar-nav>li>a{color:#fff}
    .navbar-default .navbar-nav>.active>a{background:#e4f0eb;color:#173c36}
    .container-fluid{max-width:1600px}.editor-controls,.preview-card{background:white;border:1px solid #dce4e3;border-radius:14px;padding:22px;margin-bottom:18px}
    .editor-controls{max-height:calc(100vh - 100px);overflow:auto}.editor-controls h3{font-size:18px;margin-top:0}
    details{margin:12px 0}summary{cursor:pointer;font-weight:600;padding:8px 0}.btn{border-radius:7px;margin:3px}
    .btn-primary{background:#176f5b;border-color:#176f5b}.preview-heading h2{margin-top:0;font-size:25px}.preview-heading{margin-bottom:16px}
    .checkerboard{border-radius:9px;background-color:#e9eeee;background-image:linear-gradient(45deg,#dce3e3 25%,transparent 25%),linear-gradient(-45deg,#dce3e3 25%,transparent 25%),linear-gradient(45deg,transparent 75%,#dce3e3 75%),linear-gradient(-45deg,transparent 75%,#dce3e3 75%);background-size:24px 24px;background-position:0 0,0 12px,12px -12px,-12px 0}
    #preview-stage{position:relative}#preview{display:flex;align-items:center;justify-content:center;padding:18px}#preview img{max-height:100%;max-width:100%;width:auto;height:auto;object-fit:contain;cursor:grab;touch-action:none;user-select:none}.preview-dragging #preview img{cursor:grabbing}.preview-selection{position:absolute;pointer-events:none;z-index:2}.preview-selection svg{display:block;width:100%;height:100%;overflow:visible;pointer-events:none}
    #archive_preview img{max-width:100%;max-height:320px;object-fit:contain}
    .preview-caption,.help-note,#part_detail{color:#52666a;font-size:13px;margin-top:12px}.export-actions{padding-top:18px}
    .gallery-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:18px;padding:20px 0}.gallery-card{padding:18px;background:white;border-radius:12px;border:1px solid #dce4e3;text-align:center}.gallery-card img{width:100%;height:220px}.gallery-card p{min-height:38px;color:#52666a;font-size:12px}.gallery-card a{display:block;margin-top:8px}
    @media(max-width:767px){.editor-row{display:flex;flex-direction:column}.editor-row>.col-sm-8{order:-1}.editor-controls{max-height:none}#preview{height:420px!important}}
  "
  ui <- shiny::navbarPage("hexmakR",
    id = "workspace", windowTitle = "hexmakR", selected = "designer",
    header = shiny::tagList(.cttir_brand_head(),
      shiny::tags$head(shiny::tags$style(shiny::HTML(css))),
      shiny::tags$script(shiny::HTML(.cttir_preview_script())),
      shiny::tags$script(shiny::HTML("
      document.addEventListener('click', function(event) {
        var button = event.target.closest('#apply_design,#apply_layer,#apply_color,#rename_part,#create_group,#update_group,#rename_group,#move_group');
        if (!button || !window.Shiny) return;
        var fields = button.id === 'apply_layer' ? ['fill','stroke','dx','dy','scale','lwd','angle','alpha','visible','coords_x','coords_y'] :
          button.id === 'apply_color' ? ['role','role_color'] :
          button.id === 'rename_part' ? ['part_label'] :
          button.id === 'move_group' ? ['group_dx','group_dy'] :
          ['create_group','update_group','rename_group'].indexOf(button.id) >= 0 ? ['group_label'] : ['mode','layout','shape','generic_icon','label','motif_x','motif_y','motif_scale','label_y','label_size','border_width'];
        var numeric = ['group_dx','group_dy','dx','dy','scale','lwd','angle','alpha','motif_x','motif_y','motif_scale','label_y','label_size','border_width'];
        fields.forEach(function(id) {
          var el = document.getElementById(id); if (!el) return;
          var value = el.type === 'checkbox' ? el.checked : numeric.indexOf(id) >= 0 ? Number(el.value) : el.value;
          Shiny.setInputValue(id, value, {priority:'event'});
        });
      }, true);
    "))),
    shiny::tabPanel("Designer", .cttir_editor_ui(package), value = "designer"),
    shiny::tabPanel("CTTIR Gallery", .cttir_archive_ui(package, cards), value = "gallery"),
    shiny::tabPanel("About", shiny::div(class = "preview-card",
      shiny::h2("Create your own logo"),
      shiny::p("Start with a new hexagon, pentagon or square logo. Add shapes, edit individual parts, and reuse selected gallery artwork when helpful. Save a portable project to continue later, or export PNG, SVG, PDF and an R recipe."),
      shiny::h3("CTTIR Gallery"),
      shiny::p("The CTTIR Gallery contains 45 original identities with light, dark and monochrome masters. Browsing never replaces your work; adding a part or loading a whole design is an explicit action."),
      shiny::h3("Classic designer"),
      shiny::tags$pre('hexmakr_app(workspace = "classic")'),
      shiny::h3("R workflow"),
      shiny::tags$pre('design <- logo_design("My project")\ndesign <- hex_add_part(design, "circle")\nhex_layers(design)\nhex_export(design, "my-project.svg")'),
      shiny::tags$a(href = "https://cttir.github.io/hexmakR/", "Documentation"))))
  shiny::shinyApp(ui, function(input, output, session) .cttir_editor_server(input, output, session, package))
}
