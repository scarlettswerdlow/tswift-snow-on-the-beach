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
    track_name, track_loudness, track_loudness_outlier, album_name, release_date
  ) %>%
  # Identify median to set alpha
  group_by(album_name) %>%
  mutate(
    alpha = if_else(
      condition = track_loudness == quantile(track_loudness, p = 0.5, type = 3),
      true = 0.8,
      false = 0.6
    )
  ) %>%
  ggplot(
    aes(
      x = reorder(album_name, release_date), 
      y = track_loudness, 
      color = album_name
    )
  ) +
  geom_point(aes(alpha = alpha), size = 20) +
  geom_point(
    data = function(x) subset(x, track_loudness_outlier),
    shape = 1,
    size = 20
  ) +
  geom_text(
    data = function(x) subset(x, track_loudness_outlier & str_detect(track_name, 'Snow On The Beach', negate = TRUE)),
    aes(label = str_wrap(track_name, width = 20)),
    color = 'black',
    family = 'Andale Mono',
    hjust = 'right',
    nudge_x = -0.25,
    size = 6
  ) +
  geom_text(
    data = function(x) subset(x, track_loudness_outlier & str_detect(track_name, 'Snow On The Beach')),
    aes(label = 'Snow On The Beach'),
    color = 'black',
    family = 'Andale Mono',
    hjust = 'right',
    nudge_x = -0.25,
    size = 6
  ) +
  scale_color_albums(name = 'Album') +
  scale_fill_albums(name = 'Album') +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  ggtitle('Taylor Swift Song Loudness') +
  xlab('Era') +
  ylab('Decibles') +
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
  width = 18,
  height = 12,
  units = 'in',
  dpi = 600
)
