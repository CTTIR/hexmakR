# CTTIR v5 editor. All downloads share the preview's declarative design.
.cttir_editor_ui <- function(package) {
  registry <- hex_catalog()
  shiny::tagList(
    shiny::div(class = "row editor-row",
      shiny::column(4, shiny::div(class = "editor-controls",
        shiny::h3("Design"),
        shiny::selectizeInput("identity", "Package or identity", choices = registry$name, selected = package),
        shiny::fluidRow(
          shiny::column(6, shiny::selectInput("mode", "Appearance", c("Dark"="dark", "Light"="light", "Monochrome"="mono"))),
          shiny::column(6, shiny::selectInput("layout", "Composition", c("Name inside hex"="lockup", "Artwork only"="hex", "Standalone motif"="motif")))
        ),
        shiny::selectInput("shape", "Logo shape", c("Hexagon"="hex", "Pentagon"="pentagon", "Square"="square")),
        shiny::selectizeInput("generic_icon", "Artwork", choices = c("Package motif" = "", unlist(lapply(.icons, function(group) stats::setNames(names(group), vapply(group, `[[`, character(1), "label"))), use.names = TRUE))),
        shiny::textInput("label", "Package or project name inside the frame", package),
        shiny::tags$details(shiny::tags$summary("Palette and layout"),
          shiny::selectInput("role", "Colour role", choices = names(hex_palette(hex_design(package)))),
          shiny::textInput("role_color", "Colour (name or hex)", "#193F34"),
          shiny::actionButton("apply_color", "Set colour"),
          shiny::actionButton("reset_colors", "Restore palette"),
          shiny::sliderInput("motif_x", "Artwork horizontal position", 0, 1, .5, step = .01),
          shiny::sliderInput("motif_y", "Artwork vertical position", 0, 1, .585, step = .005),
          shiny::sliderInput("motif_scale", "Artwork scale", .1, 2, 1, step = .01),
          shiny::sliderInput("label_y", "Name vertical position", 0, 1, .215, step = .005),
          shiny::sliderInput("label_size", "Name size", 6, 64, 32, step = .5),
          shiny::sliderInput("border_width", "Border width", 0, 20, 5.5, step = .5)
        ),
        shiny::actionButton("apply_design", "Apply design", class = "btn-primary"),
        shiny::tags$hr(), shiny::h3("Edit a shape"),
        shiny::selectizeInput("layer", "Vector layer", choices = NULL),
        shiny::checkboxInput("highlight", "Highlight selected shape in preview", FALSE),
        shiny::fluidRow(
          shiny::column(6, shiny::textInput("fill", "Fill (blank keeps original)", "")),
          shiny::column(6, shiny::textInput("stroke", "Stroke (blank keeps original)", ""))
        ),
        shiny::fluidRow(
          shiny::column(6, shiny::numericInput("dx", "Horizontal offset", 0, -1, 1, .01)),
          shiny::column(6, shiny::numericInput("dy", "Vertical offset", 0, -1, 1, .01))
        ),
        shiny::fluidRow(
          shiny::column(6, shiny::numericInput("scale", "Shape scale", 1, .1, 3, .05)),
          shiny::column(6, shiny::numericInput("lwd", "Stroke width", 1, 0, 30, .5))
        ),
        shiny::sliderInput("alpha", "Opacity", 0, 1, 1, step = .05),
        shiny::checkboxInput("visible", "Visible", TRUE),
        shiny::tags$details(shiny::tags$summary("Point coordinates"),
          shiny::helpText("Coordinates are local to this shape's viewport. Keep the same number of points. Blank fields keep the original geometry."),
          shiny::actionButton("load_points", "Load original coordinates"),
          shiny::textAreaInput("coords_x", "X coordinates (comma separated)", "", rows = 3),
          shiny::textAreaInput("coords_y", "Y coordinates (comma separated)", "", rows = 3)),
        shiny::actionButton("apply_layer", "Apply shape edit", class = "btn-primary"),
        shiny::actionButton("reset_layer", "Restore shape"),
        shiny::tags$hr(),
        shiny::actionButton("undo", "Undo"), shiny::actionButton("reset", "Reset design"),
        shiny::fileInput("project", "Open saved project", accept = ".json")
      )),
      shiny::column(8,
        shiny::div(class = "preview-card",
          shiny::div(class = "preview-heading", shiny::h2(shiny::textOutput("design_title", inline = TRUE)),
            shiny::textOutput("design_detail")),
          shiny::uiOutput("error"),
          shiny::div(class = "checkerboard", shiny::imageOutput("preview", height = "570px")),
          shiny::tags$p(class = "preview-caption", "Transparent exterior \u00b7 Native vector artwork \u00b7 Name inside the frame"),
          shiny::fluidRow(
            shiny::column(4, shiny::numericInput("export_width", "PNG width (pixels)", 1600, 32, 8192, 100)),
            shiny::column(8, shiny::div(class = "export-actions",
              shiny::downloadButton("png", "PNG"), shiny::downloadButton("svg", "SVG"),
              shiny::downloadButton("pdf", "PDF"), shiny::downloadButton("json", "Save project"),
              shiny::downloadButton("recipe", "R recipe"))))
        ),
        shiny::tags$p(class = "help-note", "Choose a package to load its v5 design. Apply design settings or select a vector layer to edit an individual shape. Save a project to continue editing later.")
      )
    )
  )
}

.cttir_editor_server <- function(input, output, session, package = "hexmakR") {
  current <- shiny::reactiveVal(hex_design(package))
  history <- shiny::reactiveVal(list())
  error <- shiny::reactiveVal(NULL)
  commit <- function(d) {
    .validate_design(d); hex_grob(d)
    history(utils::tail(c(history(), list(current())), 30L))
    current(d); error(NULL)
  }
  attempt <- function(expr) tryCatch(force(expr), error = function(e) error(conditionMessage(e)))
  sync_controls <- function(d) {
    shiny::updateSelectizeInput(session, "identity", selected = d$package)
    shiny::updateSelectInput(session, "mode", selected = d$mode)
    shiny::updateSelectInput(session, "layout", selected = d$layout)
    shiny::updateSelectInput(session, "shape", selected = d$shape)
    shiny::updateSelectizeInput(session, "generic_icon", selected = d$icon)
    shiny::updateTextInput(session, "label", value = d$label)
    for (id in c("motif_x", "motif_y", "motif_scale", "label_y", "label_size", "border_width"))
      shiny::updateSliderInput(session, id, value = d[[id]])
  }
  shiny::observeEvent(input$identity, {
    if (!identical(input$identity, current()$package)) attempt({
      d <- hex_design(input$identity); commit(d); sync_controls(d)
    })
  }, ignoreInit = TRUE)
  shiny::observeEvent(input$layout, {
    if (!identical(input$layout, current()$layout)) {
      shiny::updateSliderInput(session, "motif_y", value = if (input$layout == "lockup") .585 else .5)
    }
  }, ignoreInit = TRUE)
  shiny::observeEvent(input$apply_design, attempt({
    old <- current()
    d <- hex_design(old$package, input$mode, input$layout, input$label, old$colors,
      input$motif_x, input$motif_y, input$motif_scale, input$label_y,
      input$label_size, input$border_width, shape = input$shape, icon = input$generic_icon)
    # Layer IDs address geometry within a composition; changing composition
    # deliberately starts a new layer set and remains undoable.
    if (identical(d$layout, old$layout) && identical(d$icon, old$icon) && identical(d$shape, old$shape) && identical(nzchar(d$label), nzchar(old$label))) d$layers <- old$layers
    commit(d)
  }))
  shiny::observeEvent(list(current(), input$role), {
    shiny::req(input$role)
    shiny::updateTextInput(session, "role_color", value = hex_palette(current())[[input$role]])
  })
  shiny::observeEvent(input$apply_color, attempt({
    d <- current(); d$colors[[input$role]] <- input$role_color; commit(d)
  }))
  shiny::observeEvent(input$reset_colors, { d <- current(); d$colors <- list(); commit(d) })
  shiny::observeEvent(current(), {
    layers <- hex_layers(current())
    selected <- shiny::isolate(input$layer)
    if (is.null(selected) || !selected %in% layers$id) selected <- layers$id[1]
    shiny::updateSelectizeInput(session, "layer", choices = stats::setNames(layers$id,
      paste(sub("layer_", "", layers$id), layers$type, sep = " \u00b7 ")), selected = selected)
  })
  shiny::observeEvent(list(input$layer, current()), {
    shiny::req(input$layer)
    g <- hex_grob(current())$children[[input$layer]]
    shiny::req(!is.null(g))
    e <- current()$layers[[input$layer]] %||% list()
    for (id in c("fill", "stroke")) {
      value <- e[[if (id == "stroke") "col" else id]] %||% ""
      shiny::updateTextInput(session, id, value = value)
    }
    for (id in c("dx", "dy", "scale", "lwd")) shiny::updateNumericInput(session, id,
      value = e[[id]] %||% switch(id, dx = 0, dy = 0, scale = 1, lwd = g$gp$lwd %||% 1))
    shiny::updateSliderInput(session, "alpha", value = e$alpha %||% 1)
    shiny::updateCheckboxInput(session, "visible", value = e$visible %||% TRUE)
    for (axis in c("x", "y")) shiny::updateTextAreaInput(session, paste0("coords_", axis),
      value = if (is.null(e[[axis]])) "" else paste(e[[axis]], collapse = ", "))
  })
  shiny::observeEvent(input$load_points, {
    shiny::req(input$layer)
    d <- current(); d$layers <- list()
    g <- hex_grob(d)$children[[input$layer]]
    for (axis in c("x", "y")) shiny::updateTextAreaInput(session, paste0("coords_", axis),
      value = if (is.null(g[[axis]])) "" else paste(signif(as.numeric(g[[axis]]), 8), collapse = ", "))
  })
  shiny::observeEvent(input$apply_layer, attempt({
    shiny::req(input$layer)
    edits <- list(dx = input$dx, dy = input$dy, scale = input$scale, lwd = input$lwd,
      alpha = input$alpha, visible = input$visible)
    if (nzchar(input$fill)) edits$fill <- input$fill
    if (nzchar(input$stroke)) edits$col <- input$stroke
    for (axis in c("x", "y")) {
      value <- input[[paste0("coords_", axis)]]
      if (nzchar(trimws(value))) edits[[axis]] <- suppressWarnings(as.numeric(strsplit(value, "[,[:space:]]+")[[1]]))
    }
    commit(do.call(hex_edit_layer, c(list(design = current(), layer = input$layer, reset = TRUE), edits)))
  }))
  shiny::observeEvent(input$reset_layer, attempt(commit(hex_edit_layer(current(), input$layer, reset = TRUE))))
  shiny::observeEvent(input$undo, {
    h <- history()
    if (length(h)) {
      d <- h[[length(h)]]; history(h[-length(h)]); current(d); sync_controls(d); error(NULL)
    }
  })
  shiny::observeEvent(input$reset, { d <- hex_design(current()$package); commit(d); sync_controls(d) })
  shiny::observeEvent(input$project, attempt({
    d <- hex_read_design(input$project$datapath); commit(d); sync_controls(d)
  }))
  for (name in hex_catalog()$name) local({
    identity <- name
    shiny::observeEvent(input[[paste0("pick_", identity)]], {
      d <- hex_design(identity); commit(d); sync_controls(d)
      shiny::updateTabsetPanel(session, "workspace", selected = "Designer")
    })
  })
  output$design_title <- shiny::renderText(current()$package)
  output$design_detail <- shiny::renderText(paste(.identity_row(current()$package)$family,
    current()$mode, current()$shape, paste(length(current()$layers), "edited layers"), sep = " / "))
  output$error <- shiny::renderUI({
    if (!is.null(error())) shiny::div(class = "alert alert-danger", role = "alert", error())
  })
  output$preview <- shiny::renderImage({
    d <- current()
    if (isTRUE(input$highlight) && !is.null(input$layer)) {
      d <- hex_edit_layer(d, input$layer, col = "#FF4081", lwd = 4)
    }
    path <- tempfile(fileext = ".png")
    hex_export(d, path, width = 800)
    list(src = path, contentType = "image/png", alt = paste(current()$label, "design preview"))
  }, deleteFile = TRUE)
  stem <- shiny::reactive(paste0(current()$package, "-", current()$shape, "-", current()$layout, "-", current()$mode))
  for (ext in c("png", "svg", "pdf")) local({
    format <- ext
    output[[format]] <- shiny::downloadHandler(filename = function() paste0(stem(), ".", format),
      content = function(file) {
        # Shiny's temporary download path has no extension.
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
  shiny::addResourcePath("hexmakr-v5", .cttir_path("logos"))
  registry <- hex_catalog()
  cards <- lapply(seq_len(nrow(registry)), function(i) {
    row <- registry[i, ]
    shiny::div(class = "gallery-card", `data-family` = row$family,
      shiny::tags$img(src = paste0("hexmakr-v5/", row$asset_dir, "/lockup-dark.svg"), alt = row$name, loading = "lazy"),
      shiny::h4(row$name), shiny::tags$p(paste(row$family, row$kind, sep = " \u00b7 ")),
      shiny::actionButton(paste0("pick_", row$name), "Edit design"),
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
    #preview{display:flex;align-items:center;justify-content:center;padding:18px}#preview img{max-height:100%;max-width:100%;width:auto;height:auto;object-fit:contain}
    .preview-caption,.help-note{color:#52666a;font-size:13px;margin-top:12px}.export-actions{padding-top:18px}
    .gallery-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:18px;padding:20px 0}.gallery-card{padding:18px;background:white;border-radius:12px;border:1px solid #dce4e3;text-align:center}.gallery-card img{width:100%;height:220px}.gallery-card p{min-height:38px;color:#52666a;font-size:12px}.gallery-card a{display:block;margin-top:8px}
    @media(max-width:767px){.editor-row{display:flex;flex-direction:column}.editor-row>.col-sm-8{order:-1}.editor-controls{max-height:none}#preview{height:420px!important}}
  "
  ui <- shiny::navbarPage("hexmakR \u00b7 CTTIR v5", id = "workspace",
    header = shiny::tags$head(shiny::tags$style(shiny::HTML(css)), shiny::tags$script(shiny::HTML("
      document.addEventListener('click', function(event) {
        var button = event.target.closest('#apply_design,#apply_layer,#apply_color');
        if (!button || !window.Shiny) return;
        var fields = button.id === 'apply_layer' ? ['fill','stroke','dx','dy','scale','lwd','alpha','visible','coords_x','coords_y'] :
          button.id === 'apply_color' ? ['role','role_color'] : ['mode','layout','shape','generic_icon','label','motif_x','motif_y','motif_scale','label_y','label_size','border_width'];
        var numeric = ['dx','dy','scale','lwd','alpha','motif_x','motif_y','motif_scale','label_y','label_size','border_width'];
        fields.forEach(function(id) {
          var el = document.getElementById(id); if (!el) return;
          var value = el.type === 'checkbox' ? el.checked : numeric.indexOf(id) >= 0 ? Number(el.value) : el.value;
          Shiny.setInputValue(id, value, {priority:'event'});
        });
      }, true);
    "))),
    shiny::tabPanel("Designer", .cttir_editor_ui(package)),
    shiny::tabPanel("Gallery", shiny::h2("CTTIR v5 \u00b7 45 identities"),
      shiny::p("Named designs with the package name inside the hex. Choose an identity to edit its R vector artwork."),
      shiny::div(class = "gallery-grid", cards)),
    shiny::tabPanel("About", shiny::div(class = "preview-card",
      shiny::h2("One library, editable in R"),
      shiny::p("All 45 identities include the original light, dark and monochrome masters, artwork-only hexes and small icons. Edits are saved as portable projects; the approved originals remain available in the gallery."),
      shiny::h3("Generic sticker designer"),
      shiny::p("The original designer with 46 icons and 19 themes is also available:"),
      shiny::tags$pre('hexmakr_app(workspace = "classic")'),
      shiny::h3("R workflow"),
      shiny::tags$pre('design <- hex_design("phenoscapR")\nhex_layers(design)\nhex_export(design, "phenoscapR.svg")'),
      shiny::tags$a(href = "https://cttir.github.io/hexmakR/", "Documentation"))))
  shiny::shinyApp(ui, function(input, output, session) .cttir_editor_server(input, output, session, package))
}
