library(shiny)
library(ggplot2)
library(dplyr)
library(shinythemes)
library(bslib)

# Function to generate sample data
generate_sample_data <- function() {
    set.seed(123)  # Set seed for reproducibility
    dates <- seq.Date(Sys.Date() - 30, Sys.Date(), by = "day")  # Generate a sequence of dates from 30 days ago to today
    systolic <- rnorm(length(dates), mean = 120, sd = 15)  # Generate random systolic pressure values
    diastolic <- rnorm(length(dates), mean = 80, sd = 10)  # Generate random diastolic pressure values
    time_of_day <- sample(c("Morning", "Evening"), length(dates), replace = TRUE)  # Randomly assign time of day
    
    data.frame(Date = dates, Systolic = round(systolic), Diastolic = round(diastolic), TimeOfDay = time_of_day)  # Create and return data frame
}

# Define UI for application
ui <- fluidPage(
    theme = shinytheme("cosmo"),  # Aesthetic theme for the app
    tags$head(
        tags$style(HTML("body { background-color: #f5f5f5; } .well { background-color: #e6e6e6; border-radius: 10px; } h4 { color: #0066cc; }"))  # Custom styling for the UI
    ),
    
    # Application title with custom color and font
    titlePanel(
        div(style = "font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #336699; font-size: 36px;", 
            "Blood Pressure Visualiser")
    ),
    
    sidebarLayout(
        sidebarPanel(
            div(style = "color: #999999;", "If no file is selected, sample data will be used."),
            fileInput('file1', 'Choose CSV File (Optional)',  # File input for CSV file
            accept = c('text/csv', 
                       'text/comma-separated-values,text/plain', 
                       '.csv'),
            buttonLabel = "Browse...", placeholder = "No file selected"),
            tags$br(),
            dateRangeInput('dateRange', 'Choose Date Range:',  # Date range input to filter data
                           start = Sys.Date() - 30, end = Sys.Date(),
                           format = 'yyyy-mm-dd'),
            tags$hr(),
            # Styled Basic Statistics section header
            h4('Basic Statistics', style = "font-weight: bold; color: #007BFF;"),
            
            # Adding box or background to summary output
            div(style = "background-color: #f9f9f9; padding: 10px; border-radius: 5px; border: 1px solid #DDD;",
            tableOutput('summary')),  # Display the summary statistics
            
            # Add theme selection input for customizing plot appearance
            selectInput('plot_theme', 'Choose Plot Theme:', 
                        choices = c('Classic' = 'theme_classic', 'Minimal' = 'theme_minimal', 'Light' = 'theme_light', 'Dark' = 'theme_dark'))
        ),
        
        mainPanel(
           plotOutput("bpPlot", height = "500px")  # Plot output with adjusted height for a cleaner look
        ),
        
        # Set the sidebar as collapsible
        position = "left"
    )
)

# Define server logic
server <- function(input, output) {

    data <- reactive({
        # If a file is uploaded, use that. Otherwise, use the sample data.
        if (is.null(input$file1)) {
            df <- generate_sample_data()  # Use generated sample data if no file is provided
        } else {
            df <- tryCatch({
                read.csv(input$file1$datapath)  # Try reading the CSV file
            }, error = function(e) {
                # Handle error if file reading fails
                showNotification("Error reading the CSV file. Please check the file format.", type = "error")
                return(generate_sample_data())  # Return sample data if there's an error
            })
        }
        
        # Convert date column if available
        if("Date" %in% names(df)) {
            df$Date <- as.Date(df$Date)  # Convert Date column to Date type
            if (!is.null(input$dateRange)) {
                df <- df %>% filter(Date >= input$dateRange[1] & Date <= input$dateRange[2])  # Filter data based on date range input
            }
        }
        
        return(df)  # Return the filtered or generated data
    })
    
    output$bpPlot <- renderPlot({
        # Load the data
        bp_data <- data()
        
        # Determine dynamic plot limits based on data
        x_limits <- range(bp_data$Systolic, na.rm = TRUE)
        y_limits <- range(bp_data$Diastolic, na.rm = TRUE)
    
        # Initialize the base plot with the data and aesthetics
        bp_plot <- ggplot(bp_data, aes(x = Systolic, y = Diastolic, colour = TimeOfDay))
        
        # Add theme based on user input
        theme_function <- switch(input$plot_theme,  # Switch statement to apply the selected theme
                                 theme_classic = theme_classic(), 
                                 theme_minimal = theme_minimal(), 
                                 theme_light = theme_light(), 
                                 theme_dark = theme_dark(), 
                                 theme_classic())
        
        bp_plot <- bp_plot + theme_function +
            # Add labels for axes and title
            labs(
                x = "Systolic Pressure (mmHg)",
                y = "Diastolic Pressure (mmHg)",
                colour = "Time of Day",  # Label for the legend
                title = "Blood Pressure Data"
            ) +
            expand_limits(x = x_limits, y = y_limits)  # Set dynamic plot limits based on data
    
        # Define background zones for blood pressure categories using `geom_rect`
        bp_zones <- list(
            geom_rect(aes(xmin = 0, xmax = 250, ymin = 0, ymax = 150), fill = "#E40B06", color = NA, alpha = 0.1),  # Grade 3 Hypertension
            geom_rect(aes(xmin = 0, xmax = 179, ymin = 0, ymax = 109), fill = "#ED7E08", color = NA, alpha = 0.1),  # Grade 2 Hypertension
            geom_rect(aes(xmin = 0, xmax = 159, ymin = 0, ymax = 99), fill = "#F8BF78", color = NA, alpha = 0.1),   # Grade 1 Hypertension
            geom_rect(aes(xmin = 0, xmax = 139, ymin = 0, ymax = 89), fill = "#BAFDB6", color = NA, alpha = 0.1),   # Normal
            geom_rect(aes(xmin = 0, xmax = 129, ymin = 0, ymax = 84), fill = "#BAFDB6", color = NA, alpha = 0.1)    # Optimal
        )
    
        # Customize point colors and add points to the plot
        bp_points <- geom_point(size = 3, alpha = 0.8)  # Adjust point size and transparency for better visibility
    
        # Set manual color scales for "TimeOfDay"
        color_scale <- scale_color_manual(values = c("Morning" = "darkblue", "Evening" = "lightblue"))
    
        # Assemble the final plot
        final_plot <- bp_plot + bp_zones + bp_points + color_scale
    
        # Render the plot
        final_plot
    })
    
    output$summary <- renderTable({
        # Generate summary statistics for the data
        df <- data()
        summary_stats <- df %>% 
            summarise(
                Mean_Systolic = mean(Systolic, na.rm = TRUE),
                Mean_Diastolic = mean(Diastolic, na.rm = TRUE),
                Median_Systolic = median(Systolic, na.rm = TRUE),
                Median_Diastolic = median(Diastolic, na.rm = TRUE),
                Std_Systolic = sd(Systolic, na.rm = TRUE),
                Std_Diastolic = sd(Diastolic, na.rm = TRUE)
            )
        summary_stats  # Return the summary statistics
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
