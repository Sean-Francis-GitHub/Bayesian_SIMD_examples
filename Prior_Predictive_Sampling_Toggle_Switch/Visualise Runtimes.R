# This script visualises the various runtimes
# Created: 01/08/2025
# Modified: 01/08/2025


# Set working directory
setwd("~/GitHub/Bayesian_SIMD_examples/Prior_Predictive_Sampling_Toggle_Switch")

# Load packages
library(tidyverse)
library(patchwork)

# Load data
Julia_runtimes <- read.csv("output_Julia_runtime.csv") %>%
  mutate("Program" = "Julia")

R_runtimes <- read.csv("output_R_runtime.csv") %>%
  mutate("Program" = "R")

c_runtimes <- read.csv("cl_output_c_runtime.csv") %>% 
  mutate("Program" = "C")

c_fast_runtimes <- read.csv("output_c_runtime.csv") %>% 
  mutate("Program" = "C w/ memory alignment")


# Merge
runtimes <- bind_rows(Julia_runtimes, R_runtimes, c_runtimes, c_fast_runtimes) %>%
  pivot_wider(names_from = Program,
              values_from = time)

# Visualise
p1 <- runtimes %>% 
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
  scale_y_log10()+
  # scale_x_log10()+
  theme_bw()

p1_5 <- runtimes %>% 
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
  scale_y_log10()+
  scale_x_log10()+
  theme_bw()



p2 <- runtimes %>% 
  mutate("Julia" = Julia / R,
         "C" = C / R,
         "C w/ memory alignment" = `C w/ memory alignment` / R,
         "R" = R / R) %>% 
  pivot_longer(cols = -cores,
               names_to = "Program",
               values_to = "time") %>% 
  ggplot(data = , aes(x = cores, y = time, colour = Program))+
  geom_point()+
  geom_line()+
  labs(x = "Number of cores",
       y = "Comparison to baseline",
       title = "ABC Toggle Switch Program Runtime Comparison",
       subtitle = "CPU: Ryzen 5 5600 (4.4Ghz) with PBO enabled")+
  scale_x_continuous(breaks = 1:12,
                     minor_breaks = NULL)+
  scale_y_log10()+
  theme_bw()

p2_5 <- runtimes %>% 
  mutate("Julia" = Julia / R,
         "C" = C / R,
         "C w/ memory alignment" = `C w/ memory alignment` / R,
         "R" = R / R) %>% 
  pivot_longer(cols = -cores,
               names_to = "Program",
               values_to = "time") %>% 
  ggplot(data = , aes(x = cores, y = time, colour = Program))+
  geom_point()+
  geom_line()+
  labs(x = "Number of cores",
       y = "Comparison to baseline",
       title = "ABC Toggle Switch Program Runtime Comparison",
       subtitle = "CPU: Ryzen 5 5600 (4.4Ghz) with PBO enabled")+
  scale_y_log10()+
  scale_x_log10()+
  theme_bw()


p1 + p2 + p1_5 + p2_5
