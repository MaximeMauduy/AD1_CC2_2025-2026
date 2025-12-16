library(shiny)
library(rmarkdown)
library(readxl)

ui <- fluidPage(
  
  titlePanel("AD1 – CC2 (25–26) | Corrigé automatique"),
  
  sidebarLayout(
    sidebarPanel(
      
      selectInput(
        inputId = "groupe",
        label = "Sélectionnez votre groupe :",
        choices = NULL
      ),
      
      br(),
      
      downloadButton(
        outputId = "download_word",
        label = "Télécharger le corrigé (Word)"
      ),
      
      br(), br(),
      
      downloadButton(
        outputId = "download_html",
        label = "Télécharger le corrigé (HTML)"
      )
    ),
    
    mainPanel(
      h4("Aperçu du corrigé"),
      uiOutput("rapport_html")
    )
  )
)

server <- function(input, output, session) {
  
  # ---------------------------------------------------------
  # 1. Lister automatiquement les fichiers GroupeX.xlsx
  # ---------------------------------------------------------
  
  groupes_disponibles <- list.files(
    path = "data",
    pattern = "\\.xlsx$",
    full.names = FALSE
  )
  
  updateSelectInput(
    session,
    "groupe",
    choices = groupes_disponibles
  )
  
  # ---------------------------------------------------------
  # 2. Chemin du fichier sélectionné
  # ---------------------------------------------------------
  
  fichier_groupe <- reactive({
    req(input$groupe)
    normalizePath(file.path("data", input$groupe), mustWork = TRUE)
  })
  
  # ---------------------------------------------------------
  # 3. Rendu HTML DIRECTEMENT dans l’application
  # ---------------------------------------------------------
  
  output$rapport_html <- renderUI({
  req(fichier_groupe())

  out_html <- file.path("www", "corrige.html")

  rmarkdown::render(
    input = "report_template.Rmd",
    output_format = "html_document",
    output_file = out_html,
    params = list(
      data_path = fichier_groupe()
    ),
    quiet = TRUE,
    envir = new.env()
  )

  includeHTML(out_html)
})
  
  # ---------------------------------------------------------
  # 4. Téléchargement Word
  # ---------------------------------------------------------
  
  output$download_word <- downloadHandler(
  filename = function() {
    paste0("Corrige_", tools::file_path_sans_ext(input$groupe), ".docx")
  },
  content = function(file) {

    rmarkdown::render(
      input = "report_template.Rmd",
      output_format = "word_document",
      output_file = file,
      params = list(
        data_path = fichier_groupe()
      ),
      quiet = TRUE,
      envir = new.env()
    )
  }
)
  
  # ---------------------------------------------------------
  # 5. Téléchargement HTML
  # ---------------------------------------------------------
  
  output$download_html <- downloadHandler(
  filename = function() {
    paste0("Corrige_", tools::file_path_sans_ext(input$groupe), ".html")
  },
  content = function(file) {

    rmarkdown::render(
      input = "report_template.Rmd",
      output_format = "html_document",
      output_file = file,
      params = list(
        data_path = fichier_groupe()
      ),
      quiet = TRUE,
      envir = new.env()
    )
  }
)

shinyApp(ui, server)



