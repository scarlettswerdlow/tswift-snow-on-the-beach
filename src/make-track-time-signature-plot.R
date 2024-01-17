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
    track_name, track_time_signature, track_time_signature_outlier, album_name, release_date
  ) %>%
  # Fix data errors
  mutate(
    track_time_signature = if_else(
      condition = track_name == 'Last Kiss',
      true = 3,
      false = track_time_signature
    ),
    track_time_signature = if_else(
      condition = track_name == 'evermore (feat. Bon Iver)',
      true = 4,
      false = track_time_signature
    )
  ) %>% 
  group_by(album_name, release_date) %>%
  summarize(
    n_outliers = length(track_name[track_time_signature != 4]),
    tracks = if_else(
      condition = n_outliers != 0,
      true = paste(
        paste0(
          track_name[track_time_signature != 4], 
          ' (', track_time_signature[track_time_signature != 4], ')'
        ), 
        collapse = '\n'),
      false = ''
    )
  ) %>%
  ggplot(
    aes(
      x = fct_reorder(album_name, release_date), 
      y = n_outliers, 
      color = album_name
    )
  ) +
  geom_segment(
    aes(
      xend = fct_reorder(album_name, release_date), 
      y = 0,
      yend = n_outliers
    ), 
    color = 'black'
  ) +
  geom_point(alpha = 0.5, size = 20) +
  geom_text(
    data = function(x) subset(x, album_name != 'Red'),
    aes(label = tracks),
    color = 'black',
    family = 'Andale Mono',
    size = 6,
    hjust = 'right',
    nudge_x = -0.25
  ) +
  geom_text(
    data = function(x) subset(x, album_name == 'Red'),
    aes(label = tracks),
    color = 'black',
    family = 'Andale Mono',
    size = 6,
    hjust = 'left',
    nudge_x = 0.25
  ) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(breaks = c(0, 1, 2)) +
  scale_color_albums() +
  ggtitle('Taylor Swift Song Time Signatures') +
  xlab('Era') +
  ylab('Number of Songs Not in 4 Time Signature') +
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
  width = 18,
  height = 12,
  units = 'in',
  dpi = 600
)
