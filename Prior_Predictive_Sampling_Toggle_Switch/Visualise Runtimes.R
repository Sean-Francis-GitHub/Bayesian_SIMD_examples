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

cl_runtimes <- read.csv("cl_output_c_runtime.csv") %>%
  mutate("Program" = "C")

c_runtimes <- read.csv("output_c_runtime.csv") %>% 
  mutate("Program" = "C w/ memory alignment")


# Merge
runtimes <- bind_rows(Julia_runtimes, R_runtimes, c_runtimes, cl_runtimes) %>%
  pivot_wider(names_from = Program,
              values_from = time)

# Visualise
p1 <- runtimes %>% 
  rename("C w/ memory\nalignment" = `C w/ memory alignment`) %>% 
  pivot_longer(cols = -cores,
               names_to = "Program",
               values_to = "time") %>% 
  ggplot(data = ., aes(x = cores, y = time, colour = Program))+
  geom_point(size = 2)+
  geom_line(linewidth = 1)+
  labs(x = "Number of threads",
       y = "Time (s)")+
  scale_x_continuous(breaks = 1:12,
                     minor_breaks = NULL)+
  scale_y_log10()+
  # scale_x_log10()+
  theme_bw()+
  theme(text=element_text(size = 15))


p1_5 <- runtimes %>% 
  rename("C w/ memory\nalignment" = `C w/ memory alignment`) %>% 
  pivot_longer(cols = -cores,
               names_to = "Program",
               values_to = "time") %>% 
  ggplot(data = ., aes(x = cores, y = time, colour = Program))+
  geom_point(size = 2)+
  geom_line(linewidth = 1)+
  labs(x = "Number of threads",
       y = "Time (s)")+
  scale_y_log10()+
  scale_x_log10()+
  theme_bw()+
  theme(text=element_text(size = 15))




p2 <- runtimes %>% 
  mutate("baseline" = runtimes %>% filter(cores == 1) %>% pull(R),
         "Julia" = baseline / Julia,
         "C" = baseline / C,
         "C w/ memory alignment" = baseline / `C w/ memory alignment`,
         "R" = baseline / R) %>% 
  rename("C w/ memory\nalignment" = `C w/ memory alignment`) %>% 
  pivot_longer(cols = -cores,
               names_to = "Program",
               values_to = "time") %>% 
  filter(Program != "baseline") %>% 
  # mutate("linetype" = if_else(Program == "baseline", true = "full", false = "dashed")) %>% 
  ggplot(data = ., aes(x = cores, y = time, colour = Program))+# , linetype = linetype))+
  geom_point(size = 2)+
  geom_line(linewidth = 1)+
  labs(x = "Number of threads",
       y = "Speedup from single-threaded R")+
  scale_y_log10()+
  scale_x_continuous(breaks = 1:12,
                     minor_breaks = NULL)+
  theme_bw()+
  guides(linetype = "none")+
  theme(text=element_text(size = 15))

p2_5 <- runtimes %>% 
  mutate("baseline" = runtimes %>% filter(cores == 1) %>% pull(R),
         "Julia" = baseline / Julia,
         "C" = baseline / C,
         "C w/ memory alignment" = baseline / `C w/ memory alignment`,
         "R" = baseline / R) %>% 
  pivot_longer(cols = -cores,
               names_to = "Program",
               values_to = "time") %>% 
  filter(Program != "baseline") %>% 
  # mutate("linetype" = if_else(Program == "baseline", true = "full", false = "dashed")) %>% 
  ggplot(data = ., aes(x = cores, y = time, colour = Program))+# , linetype = linetype))+
  geom_point(size = 2)+
  geom_line(linewidth = 1)+
  labs(x = "Number of threads",
       y = "Speedup from single-threaded R")+
  scale_y_log10()+
  scale_x_log10()+
  theme_bw()+
  guides(linetype = "none")+
  theme(text=element_text(size = 15))



plots <- p1 + p2 + p1_5 + p2_5

plots + plot_annotation(
  title = "ABC Toggle Switch Program Runtime Comparison",
  subtitle = "CPU: Ryzen 5 5600 (4.4Ghz) with PBO enabled")
