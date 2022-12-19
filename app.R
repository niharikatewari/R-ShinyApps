#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinycssloaders)
library(wordcloud2)
library(ggplot2)
library(shinydashboard)
library(dplyr)
library(tidytext)
library(DT)

nbClassifier <- load("data/NaiveBayesClassifier.rda")
hotels <- readRDS("data/hotels.rds")

source("helper/scrapeHotelReview.R")
source("helper/featureExtraction.R")

ui <- dashboardPage(
  
  dashboardHeader(title = "Hotel Review"),
  
  dashboardSidebar(
    
    selectInput(
      "selectHotel",
      label = h3("Pilih Hotel"),
      setNames(hotels$link, hotels$name)
    ),
    fluidPage(
      submitButton("Submit"),
      hr(),
      helpText(
        "Data review hotel akan diambil langsung (scraping) dari website ",
        a("Tripadvisor", href = "https://www.tripadvisor.com/"),
        ". Mohon tunggu beberapa saat."
      ),
      hr(),
      helpText(
        "Review hotel yang di-scrape akan di klasifikasikan dengan Naive Bayes"
      ),
      hr(),
      helpText(
        "Peringatan: Mungkin terjadi lost connection saat scraping data. Refresh halaman jika terjadi error.", style = "color:#d9534f"
      )
    )
  ),
  
  dashboardBody(
    fluidRow(
      valueBoxOutput("total_review"),
      valueBoxOutput("happy_review"),
      valueBoxOutput("not_happy_review")
    ),
    fluidRow(
      box(
        title = "Hotel Review + Klasifikasi Sentiment",
        solidHeader = T,
        width = 12,
        collapsible = T,
        div(DT::dataTableOutput("table_review") %>% withSpinner(color="#1167b1"), style = "font-size: 70%;")
      ),
    ),
    fluidRow(
      box(title = "Wordcloud",
          solidHeader = T,
          width = 6,
          collapsible = T,
          wordcloud2Output("wordcloud") %>% withSpinner(color="#1167b1")
      ),
      box(title = "Word Count",
          solidHeader = T,
          width = 6,
          collapsible = T,
          plotOutput("word_count") %>% withSpinner(color="#1167b1")
      )
    ),
    fluidRow(
      box(title = "Sentimen Negatif / Positif yang Paling Umum",
          solidHeader = T,
          width = 12,
          collapsible = T,
          plotOutput("kontribusi_sentimen") %>% withSpinner(color="#1167b1")
      )
    )
  )
)

server <- function(input, output) {
  
  data <- reactive({
    get_hotel_reviews(input$selectHotel)
  })
  
  dataNB <- reactive({
    reviews <- data()$Review
    withProgress({
      setProgress(message = "Ekstrak Fitur...")
      newData <- extract_feature(reviews)
    })
    withProgress({
      setProgress(message = "Klasifikasi Sentiment...")
      pred <- predict(get(nbClassifier), newData)
    })
    data.frame(Nama = data()$Nama, Review = data()$Review, Prediksi = as.factor(pred), stringsAsFactors = FALSE)
  })
  
  dataWord <- reactive({
    v <- sort(colSums(as.matrix(create_dtm(data()$Review))), decreasing = TRUE)
    data.frame(Kata=names(v), Jumlah=as.integer(v), row.names=NULL, stringsAsFactors = FALSE) %>%
      filter(Jumlah > 0)
  })
  
  output$table_review <- renderDataTable(datatable({
    dataNB()
  }))
  
  output$total_review <- renderValueBox({
    valueBox(
      "Total", 
      paste0(nrow(dataNB()), " review"),
      icon = icon("pen"),
      color = "blue"
    )
  })
  
  output$happy_review <- renderValueBox({
    valueBox(
      "Happy", 
      paste0(nrow(dataNB() %>% filter(Prediksi == "happy")), " pengunjung merasa senang"),
      icon = icon("smile"),
      color = "green")
  })
  
  output$not_happy_review <- renderValueBox({
    valueBox(
      "Not Happy",
      paste0(nrow(dataNB() %>% filter(Prediksi == "not happy")), " pengunjung merasa tidak senang"), 
      icon = icon("frown"),
      color = "red")
  })
  
  output$wordcloud <- renderWordcloud2({
    wordcloud2(top_n(dataWord(), 50, Jumlah))
  })
  
  output$word_count <- renderPlot({
    countedWord <- dataWord() %>%
      top_n(10, Jumlah) %>%
      mutate(Kata = reorder(Kata, Jumlah))
    
    ggplot(countedWord, aes(Kata, Jumlah, fill = -Jumlah)) +
      geom_col() +
      guides(fill = FALSE) +
      theme_minimal()+
      labs(x = NULL, y = "Word Count") +
      ggtitle("Most Frequent Words") +
      coord_flip()
  })
  
  output$kontribusi_sentimen <- renderPlot({
    sentiments <- dataWord() %>% 
      inner_join(get_sentiments("bing"), by = c("Kata" = "word"))
    
    positive <- sentiments %>% filter(sentiment == "positive") %>% top_n(10, Jumlah) 
    negative <- sentiments %>% filter(sentiment == "negative") %>% top_n(10, Jumlah)
    sentiments <- rbind(positive, negative)
    
    sentiments <- sentiments %>%
      mutate(Jumlah=ifelse(sentiment =="negative", -Jumlah, Jumlah))%>%
      mutate(Kata = reorder(Kata, Jumlah))
    
    ggplot(sentiments, aes(Kata, Jumlah, fill=sentiment))+
      geom_bar(stat = "identity")+
      theme(axis.text.x = element_text(angle = 90, hjust = 1))+
      ylab("Kontibusi Sentimen")
  })
}

shinyApp(ui, server)