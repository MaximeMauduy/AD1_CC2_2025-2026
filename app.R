library(shiny)
library(rmarkdown)
library(readxl)

ui <- fluidPage(
  
  titlePanel("AD1 – CC2 (25–26) | Corrigé automatique"),
  
  sidebarLayout(
    sidebarPanel(
      
      selectInput(
        inputId = "groupe",
        label = "Sélectionnez votre fichier de données :",
        choices = NULL
      ),
      
      br(),
      
      actionButton(
        "generate",
        "Générer le corrigé"
      ),
      
      br(), br(),
      
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
  # 1. Lister TOUS les fichiers du dossier data
  # ---------------------------------------------------------
  
  fichiers_data <- list.files(
    path = "data",
    pattern = "\\.xlsx$",
    full.names = FALSE
  )
  
  updateSelectInput(
    session,
    "groupe",
    choices = fichiers_data
  )
  
  # ---------------------------------------------------------
  # 2. Chemin du fichier sélectionné
  # ---------------------------------------------------------
  
  fichier_groupe <- reactive({
    req(input$groupe)
    file.path("data", input$groupe)
  })
  
  # ---------------------------------------------------------
  # 3. Génération du rapport (HTML) — déclenchée EXPLICITEMENT
  # ---------------------------------------------------------
  
  rapport_html_gen <- eventReactive(input$generate, {
    
    tmp_rmd  <- tempfile(fileext = ".Rmd")
    tmp_html <- tempfile(fileext = ".html")
    
    file.copy("report_template.Rmd", tmp_rmd, overwrite = TRUE)
    
    rmarkdown::render(
      input = tmp_rmd,
      output_file = tmp_html,
      params = list(
        data_path = fichier_groupe()
      ),
      quiet = FALSE
    )
    
    tmp_html
  })
  
  output$rapport_html <- renderUI({
    req(rapport_html_gen())
    print(fichier_groupe())
    
    tags$iframe(
      src = rapport_html_gen(),
      width = "100%",
      height = "800px",
      style = "border: none;"
    )
  })
  
  # ---------------------------------------------------------
  # 4. Téléchargement Word
  # ---------------------------------------------------------
  
  output$download_word <- downloadHandler(
    filename = function() {
      paste0("Corrige_", tools::file_path_sans_ext(input$groupe), ".docx")
    },
    content = function(file) {
      
      tmp_rmd <- tempfile(fileext = ".Rmd")
      file.copy("report_template.Rmd", tmp_rmd, overwrite = TRUE)
      
      rmarkdown::render(
        input = tmp_rmd,
        output_format = "word_document",
        output_file = file,
        params = list(
          data_path = fichier_groupe()
        ),
        quiet = FALSE
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
      
      tmp_rmd <- tempfile(fileext = ".Rmd")
      file.copy("report_template.Rmd", tmp_rmd, overwrite = TRUE)
      
      rmarkdown::render(
        input = tmp_rmd,
        output_format = "html_document",
        output_file = file,
        params = list(
          data_path = fichier_groupe()
        ),
        quiet = FALSE
      )
    }
  )
}

shinyApp(ui, server)


