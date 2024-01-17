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

# Violin plot
p <- tracks_analytics_df %>%
  left_join(
    albums_raw_df[c('album_name', 'release_date')],
    by = 'album_name'
  ) %>%
  select(
    track_name, track_valence, track_valence_outlier, album_name, release_date
  ) %>%
  # Identify median to set alpha
  group_by(album_name) %>%
  mutate(
    alpha = if_else(
      condition = track_valence == quantile(track_valence, p = 0.5, type = 3),
      true = 0.8,
      false = 0.6
    )
  ) %>%
  ggplot(
    aes(
      x = reorder(album_name, release_date), 
      y = track_valence, 
      color = album_name
    )
  ) +
  geom_point(aes(alpha = alpha), size = 20) +
  geom_point(
    data = function(x) subset(x, track_valence_outlier),
    shape = 1,
    size = 20
  ) +
  geom_text(
    data = function(x) subset(x, track_valence_outlier),
    aes(label = str_wrap(track_name, width = 12)),
    color = 'black',
    family = 'Andale Mono',
    size = 6,
    vjust = 'bottom',
    nudge_y = 0.045
  ) +
  scale_color_albums(name = 'Album') +
  scale_fill_albums(name = 'Album') +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  ggtitle('Taylor Swift Song Valence') +
  xlab('Era') +
  ylab('Song Valence') +
  guides(color = 'none', fill = 'none', alpha = 'none') +
  theme_minimal() +
  theme(
    text = element_text(family = 'Andale Mono', size = 25),
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
