# This script visualises the various runtimes
# Created: 01/08/2025
# Modified: 01/08/2025


# Load packages
library(tidyverse)

# Load data
Julia_runtimes <- read.csv("output_Julia_runtime.csv") %>%
  mutate("Program" = "Julia")

R_runtimes <- read.csv("output_R_runtime.csv") %>%
  mutate("Program" = "R")


# Merge
runtimes <- Julia_runtimes %>%
  bind_rows(R_runtimes) %>%
  pivot_wider(id_cols = cores,
              values_from = )

# Visualise
ggplot(data = runtimes, aes(x = cores, y = time, colour = Program))+
  geom_point()+
  geom_line()+
  labs(x = "Number of cores",
       y = "Time (s)",
       title = "ABC Toggle Switch Program Runtime Comparison",
       subtitle = "CPU: Ryzen 5 5600 (4.4Ghz) with PBO enabled")+
  scale_x_continuous(breaks = 1:12,
                     minor_breaks = NULL)+
  scale_y_log10()+
  theme_bw()
