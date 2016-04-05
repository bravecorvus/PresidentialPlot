plotday365 <- ggplot(day365, aes(x = Percentage, y = Change.In.Polling.Percentage, size = Searched, fill=Candidate, label=Candidate)) +
  labs(x="Total Percentage of Democrat Vote", y="Change in Percentage")+
  geom_point(shape = 21, show_guide = FALSE) +
  geom_text(size=4)+
  # map z to area and make larger circles
  scale_size_area(max_size = 70) +
  scale_x_continuous(breaks = c(20, 40, 60, 80), limit = c(0, 100), 
                     expand = c(0, 0)) +
  scale_y_continuous(breaks = c(-40, -20, 0, 20, 40), limit = c(-60, 60), 
                     expand = c(0, 0)) +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        plot.title = element_text(size = rel(1.5), face = "bold", vjust = 1.5),
        axis.title=element_blank(),
        axis.text.x=element_text(size=10),
        axis.text.y=element_text(size=10))+

ggtitle(paste(as.character(day365$Date[1]), " Democrats"))
ggsave(filename="/Users/andrewlee/Documents/School/CS125/Final Project/DEMPlots/DEMday365.png")

