library(shiny)
library(shinydashboard)
library(ggplot2)
library(hrbrthemes)
shinyUI(
  dashboardPage(
    dashboardHeader(title = "Iris Dataset Analysis"),
    dashboardSidebar(
      sidebarMenu(
      menuItem("Iris Dataset", tabName = "irisdataset"),
       menuSubItem("Sepal Properties" , tabName = "sepal", icon = icon("tree")),
       menuSubItem("Petal Properties", tabName = "petal", icon = icon("tree")),
      sliderInput("bins","Number of Breaks",1,100,50),
      menuItem("Detailed Analysis", badgeLabel = "New", badgeColor = "orange")
    )),
    dashboardBody(
      tabItems(
        tabItem(tabName = "irisdataset",
                h1("About Iris Dataset"),
                "The Iris dataset was used in R.A. Fisher's classic 1936 paper, The Use of Multiple Measurements in Taxonomic Problems, and can also be found on the UCI Machine Learning Repository.",
                br(),
                "It includes three iris species with 50 samples each as well as some properties about each flower.",br(),
                "One flower species is linearly separable from the other two, but the other two are not linearly separable from each other.",br(),
                fluidRow(column(12,
                dataTableOutput("iristable")))
        ),
        tabItem(tabName = "sepal",
                fluidRow(
                  box(plotOutput("histogram")),
                  box(plotOutput("histogramsw"))
                ),
                fluidRow(
                  box(plotOutput("density")),
                  box(plotOutput("densitysw"))
                )),
        tabItem(tabName = "petal",
                fluidRow(
                  box(plotOutput("histogrampl")),
                  box(plotOutput("histogrampw"))
                ),
                fluidRow(
                  box(plotOutput("densitypl")),
                  box(plotOutput("densitypw"))
                ))
           )
    )
  )
)