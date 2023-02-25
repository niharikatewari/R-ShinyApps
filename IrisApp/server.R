library(shiny)
library(shinydashboard)
library(ggplot2)
library(hrbrthemes)

shinyServer(function(input,output){
  output$iristable <- renderDataTable(iris)
  output$histogram <- renderPlot({
    ggplot(iris, aes(x = iris$Sepal.Length))+geom_histogram(bins =input$bins, fill="#69b3a2", color="#e9ecef", alpha=0.9) + theme_ipsum() + ggtitle("Sepal Length")
          })
    output$histogramsw <- renderPlot({
    ggplot(iris, aes(x = iris$Sepal.Width))+geom_histogram(bins =input$bins,  fill="#69b3a2", color="#e9ecef", alpha=0.9) + theme_ipsum() + ggtitle("Sepal Width")
    })
  output$histogrampl <- renderPlot({
    ggplot(iris, aes(x = iris$Petal.Length))+geom_histogram(bins =input$bins,  fill="#69b3a2", color="#e9ecef", alpha=0.9) + theme_ipsum() + ggtitle("Petal Length")
    })
  output$histogrampw <- renderPlot({
    ggplot(iris, aes(x = iris$Petal.Width))+geom_histogram(bins =input$bins,  fill="#69b3a2", color="#e9ecef", alpha=0.9) + theme_ipsum() + ggtitle("Petal Width")
    })
  output$density <- renderPlot({
    ggplot(iris, aes(x = iris$Sepal.Length, y = iris$Sepal.Width, color = factor(iris$Species)))+geom_point(size = 5) + theme_ipsum() + ggtitle("Sepal Length and Sepal Width as per Species")
  })
  output$densitysw <- renderPlot({
    ggplot(iris, aes(x = iris$Sepal.Length, y = iris$Sepal.Width))+geom_bin2d(bins = input$bins) + scale_fill_viridis_c() + theme_ipsum()+ ggtitle("Sepal Length and Sepal Width as per Species")
  })
  output$densitypl <- renderPlot({
    ggplot(iris, aes(x = iris$Petal.Length, y = iris$Petal.Width, color = factor(iris$Species)))+geom_point(size = 5) + theme_ipsum() + ggtitle("Petal Length and Petal Width as per Species")
  })
  output$densitypw <- renderPlot({
    ggplot(iris, aes(x = iris$Petal.Length, y = iris$Petal.Width))+geom_bin2d(bins = input$bins) + scale_fill_viridis_c()+ theme_ipsum() + ggtitle("Petal Length and Petal Width as per Species")
  })
})