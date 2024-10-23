# Blood Pressure Visualiser

This Shiny application provides an interactive way to visualise blood pressure data. Users can upload their own CSV files or use sample data to explore blood pressure measurements over time. The application also includes an option to customize the theme of the plot for a personalised experience.

## Features

- **Data Input**: Users can upload a CSV file with blood pressure data. If no file is uploaded, sample data will be generated automatically.
- **Date Range Filter**: The app allows users to filter the displayed data based on a specific date range.
- **Customisable Plot Themes**: Users can choose from four different themes (`Classic`, `Minimal`, `Light`, `Dark`) to change the appearance of the plot.
- **Basic Statistics**: A summary of basic statistics, including mean, median, and standard deviation for systolic and diastolic pressure values, is provided.
- **Blood Pressure Categories**: The plot features color-coded background zones indicating different blood pressure categories (e.g., optimal, normal, hypertension grades).

## Running the App on Shinylive

You can run the app directly in your browser using [Shinylive](https://shinylive.io/). Shinylive allows you to run Shiny applications without needing to install R or any additional software.

To get started:

1. Visit [Shinylive](https://shinylive.io/).
2. Upload your Shiny app files, including this script, to the platform.
3. Shinylive will provide a link for you to run the app directly in your browser.

## Installation (Local Option)

To run this Shiny application locally, make sure you have R and the following R packages installed:

```r
install.packages(c("shiny", "ggplot2", "dplyr", "shinythemes", "bslib"))
```

## Running the App Locally

You can run the app locally using the following command in your R console:

```r
shiny::runApp("path/to/your/app")
```
Replace `path/to/your/app` with the path where you saved the R script.

## CSV File Format

The CSV file should include the following columns:
- **Date**: The date of the measurement (in `yyyy-mm-dd` format).
- **Systolic**: The systolic blood pressure value.
- **Diastolic**: The diastolic blood pressure value.
- **TimeOfDay**: Indicates whether the reading was taken in the `Morning` or `Evening`.

If the CSV file is improperly formatted or cannot be read, the application will revert to using the sample data and display a notification.

## Usage

1. Launch the app using RStudio or R, or use [Shinylive](https://shinylive.io/) to run it in your browser.
2. Choose a CSV file to upload (optional) or use the sample data.
3. Filter the data by selecting a date range.
4. Customise the plot theme using the dropdown menu.
5. View the blood pressure plot and summary statistics in the main panel.

## Plot Customisation

The app includes four customisable themes for the plot:
- **Classic**: A traditional, clean theme.
- **Minimal**: A theme with minimal visual clutter.
- **Light**: A light-colored theme for better readability.
- **Dark**: A dark-colored theme, ideal for viewing in low-light environments.

## Error Handling

If there are issues reading the CSV file (e.g., incorrect format or missing data), a notification will appear, and sample data will be used instead.

## License

This project is open source and available under the [MIT License](https://opensource.org/licenses/MIT).
