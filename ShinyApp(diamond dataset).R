
library(shiny)
library(tidyverse)
View(diamonds)
names(diamonds)

ui <- fluidPage(textInput(inputId = "cut", 
                          label = "Quality :  ", 
                          value ="",
                          placeholder = "Ideal"),
                
                
                selectInput(inputId = "color", 
                            label = "color", 
                            choices = list(best = "D",
                                           better = "E",
                                           good ="F",
                                           medium="G",
                                           normal="H",
                                           poor="I",
                                           worst = "J")),
                
                
                sliderInput(inputId = "price", 
                            label = "Price: ", 
                            min = min(diamonds$price), 
                            max = max(diamonds$price),
                            value = c(min(diamonds$price),
                                      max(diamonds$price)),
                            sep =""),
                
                
                plotOutput(outputId = "nameplot")
)


server <- function(input,output){
  output$nameplot <- renderPlot({
    diamonds %>%
      filter(color==input$color,
             cut==input$cut) %>%
      ggplot(aes(x=price,
                 y=clarity))+
      geom_line()+
      scale_x_continuous(limits = input$price)+
      theme_bw()
  })
}

shinyApp(ui = ui, server = server)