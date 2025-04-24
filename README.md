README for University Ranking Dashboard Project

Project Overview

This project is a university ranking dashboard that provides an interactive way to explore and analyze global university rankings. The dashboard uses data from usNews_ranking.csv and is implemented in R using Shiny. The project is part of the CSS Assessment II and includes interactive visualizations, maps, and analysis tools to explore university rankings by various metrics such as score, enrollment, and founding year.

Files Included

1. usNews_ranking.csv

Description: Contains the dataset used for the project.

Columns:
  
  numeric_rank: The ranking of the university.

country: The country where the university is located.

city: The city where the university is located.

score: The overall score of the university.

enrollment: The number of students enrolled at the university.

year_founded: The year the university was established.

lat: Latitude of the university’s location.

long: Longitude of the university’s location.

location: The full address or location description.

2. University Ranking.rproj

Description: An RStudio project file to organize and manage the workspace for the project.

3. CSS assessment II.R

Description: A R script used in the project for data preprocessing, visualization, and analysis.

4. CSS Assessment II.qmd

Description: A Quarto markdown file containing the written report and supplementary analysis for the CSS Assessment II.

Purpose: To present analysis results and document findings in a reproducible format.

5. CSS assessment II.HTML

Description: The HTML file generated from the Quarto markdown file.

Purpose: A web-viewable version of the report.

6. CSS Assessment II_files

Description: A folder containing resources (e.g., images, scripts, or styles) used in the HTML report.

7. app.R

Description: The main Shiny app script.

Purpose: Powers the interactive dashboard with the following features:
  
  Scatter plot to analyze the relationship between score, enrollment, and rank.

Year founded analysis for exploring historical trends.

Interactive map for geographical visualization of universities.

Key Components:
  
  UI: Defines the layout and widgets for user interaction.

Server: Contains the logic for generating plots and maps based on user inputs.

How to Run the Project

Set Up Environment:
  
  Ensure R and RStudio are installed on your system.

Install required R packages: shiny, ggplot2, dplyr, leaflet, ggrepel.

install.packages(c("shiny", "ggplot2", "dplyr", "leaflet", "ggrepel"))

Open Project:
  
  Open University Ranking.rproj in RStudio to initialize the workspace.

Run the Shiny App:
  
  Open app.R in RStudio and click the "Run App" button to launch the interactive dashboard.

Access the Report:
  
  Open the CSS Assessment II.qmd or the corresponding HTML file to view the analysis and report.

Project Structure

.
├── usNews_ranking.csv            # Dataset
├── University Ranking.rproj      # RStudio project file
├── CSS assessment II.R           # R scripts folder
├── CSS Assessment II.qmd         # Quarto markdown report
├── CSS Assessment II.html        # HTML report
├── CSS Assessment II_files       # Resources for the HTML report
└── app.R                         # Shiny app script

References

Horstschräer, J. (2012). University rankings in action? The importance of rankings and an excellence competition for university choice of high-ability students. Economics of Education Review, 31(6), 1162–1176. https://doi.org/10.1016/j.econedurev.2012.07.018

Nye, J. S., Jr. (2010). The futures of American power: Dominance and decline in perspective. Foreign Affairs, 89(6), 2–12.

Contact Information

For questions or feedback, please contact the project author.