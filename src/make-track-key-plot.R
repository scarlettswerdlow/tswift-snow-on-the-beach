library(tidyverse)
library(taylor)
library(extrafont)

args = commandArgs(trailingOnly = TRUE)
if (length(args) < 3) {
    stop("Three arguments must be supplied: (filepath to processed tracks), (filepath to raw albums), and (filepath to save plot).n", call. = FALSE)
}
tracks_analytics_fp <- args[1]
albums_raw_fp <- args[2]
plot_fp <- args[3]

tracks_analytics_df <- read_csv(tracks_analytics_fp)
albums_raw_df <- read_csv(albums_raw_fp)

p <- tracks_analytics_df %>%
  left_join(
    albums_raw_df[c('album_name', 'release_date')],
    by = 'album_name'
  ) %>%
  select(
    track_name, track_key, track_key_outlier, album_name, release_date
  ) %>%
  mutate(
    # Recode track key based on https://en.wikipedia.org/wiki/Pitch_class
    track_key_recoded = recode_factor(
      track_key,
      '0' = 'C',
      '1' = 'C♯, D♭',
      '2' = 'D',
      '3' = 'D♯, E♭',
      '4' = 'E',
      '5' = 'F',
      '6' = 'F♯, G♭',
      '7' = 'G',
      '8' = 'G♯, A♭',
      '9' = 'A',
      '10' = 'A♯, B♭',
      '11' = 'B',
      .ordered = TRUE
    )
  ) %>%
  group_by(album_name, release_date, track_key_recoded) %>%
  summarize(
    n = n(),
    n_outliers = sum(track_key_outlier),
    tracks = paste(track_name, collapse = ", ")
  ) %>%
  ggplot(
    aes(
      x = fct_reorder(album_name, release_date), 
      y = track_key_recoded, 
      color = album_name,
      size = n
    )
  ) +
  geom_point(alpha = 0.5) +
  #geom_point(
    #data = function(x) subset(x, n_outliers > 0), 
    #shape = 1, 
    #stroke = 1
  #) +
  #geom_text(
  #  data = function(x) subset(x, n_outliers > 0),
  #  aes(label = str_wrap(tracks, width = 18)),
  #  color = 'black',
  #  family = 'Andale Mono',
  #  nudge_y = -0.25,
  #  size = 4,
  #  vjust = 'top',
  #) +
  scale_size_continuous(range = c(5, 30)) +
  scale_color_albums() +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  ggtitle('Taylor Swift Song Keys') +
  xlab('Era') +
  ylab('Song Key') +
  guides(color = 'none', size = 'none') +
  theme_minimal() +
  theme(
    text = element_text(family = 'Andale Mono', size = 25),
    axis.text.y = element_text(family = 'Arial Unicode MS'),
    plot.title = element_text(margin = margin(10, 0, 10, 0)),
    axis.title.x = element_text(margin = margin(10, 0, 10, 0)),
    axis.title.y = element_text(margin = margin(0, 10, 0, 10))
  )

extrafont::loadfonts()
ggsave(
  plot = p,
  filename = plot_fp, 
  device = 'jpeg',
  width = 18,
  height = 12,
  units = 'in',
  dpi = 600
)