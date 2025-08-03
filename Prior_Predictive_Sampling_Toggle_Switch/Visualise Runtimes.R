# This script visualises the various runtimes
# Created: 01/08/2025
# Modified: 01/08/2025


# Set working directory
setwd("~/GitHub/Bayesian_SIMD_examples/Prior_Predictive_Sampling_Toggle_Switch")

# Load packages
library(tidyverse)

# Load data
Julia_runtimes <- read.csv("output_Julia_runtime.csv") %>%
  mutate("Program" = "Julia")

R_runtimes <- read.csv("output_R_runtime.csv") %>%
  mutate("Program" = "R")

c_runtimes <- read.csv("output_c_runtime.csv") %>% 
  mutate("Program" = "C")


# Merge
runtimes <- bind_rows(Julia_runtimes, R_runtimes, c_runtimes) %>%
  pivot_wider(names_from = Program,
              values_from = time)

# Visualise
runtimes %>% 
  pivot_longer(cols = -cores,
               names_to = "Program",
               values_to = "time") %>% 
  ggplot(data = , aes(x = cores, y = time, colour = Program))+
  geom_point()+
  geom_line()+
  labs(x = "Number of cores",
       y = "Time (s)",
       title = "ABC Toggle Switch Program Runtime Comparison",
       subtitle = "CPU: Ryzen 5 5600 (4.4Ghz) with PBO enabled")+
  scale_x_continuous(breaks = 1:12,
                     minor_breaks = NULL)+
  scale_y_log10(
    # limits = c(10, NA)
  )+
  theme_bw()
